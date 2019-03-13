import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    var particlesPipelineState: MTLComputePipelineState!
    var renderPipelineState: MTLRenderPipelineState!

    var emitters: [Emitter] = []

    init?(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else { return nil }
        Renderer.device = device
        self.commandQueue = commandQueue
        super.init()
        metalView.delegate = self
        metalView.framebufferOnly = false
        metalView.clearColor = MTLClearColor(red: 0.2, green: 0.2,
                                             blue: 0.2, alpha: 1)
        buildPipelineStates()

        let snowEmitter = snow(size: metalView.drawableSize)
        snowEmitter.position = [0, Float(metalView.drawableSize.height), 0]
        emitters.append(snowEmitter)

        let fireEmitter = fire(size: metalView.drawableSize)
        fireEmitter.position = [0, -10, 0]
        emitters.append(fireEmitter)

        let experimentEmitter = experiment(size: metalView.drawableSize)
        experimentEmitter.position = [0, 0, 0]
        emitters.append(experimentEmitter)
    }

    private func buildPipelineStates() {
        do {
            guard let library = Renderer.device.makeDefaultLibrary(),
                let function = library.makeFunction(name: "compute") else { return }

            // particle update pipeline state
            particlesPipelineState = try Renderer.device.makeComputePipelineState(function: function)

            // render pipeline state
            let vertexFunction = library.makeFunction(name: "vertex_particle")
            let fragmentFunction = library.makeFunction(name: "fragment_particle")
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction

            if let colorAttachment = descriptor.colorAttachments[0] {
                colorAttachment.pixelFormat = .bgra8Unorm
                colorAttachment.isBlendingEnabled = true
                colorAttachment.rgbBlendOperation = .add
                colorAttachment.sourceRGBBlendFactor = .sourceAlpha
                colorAttachment.destinationRGBBlendFactor = .one
            }

            renderPipelineState = try
                Renderer.device.makeRenderPipelineState(descriptor: descriptor)
            renderPipelineState = try Renderer.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    public func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable else { return }

        let deltaTime = 1.0 / Float(view.preferredFramesPerSecond)

        for emitter in emitters {
            emitter.emit(deltaTime: deltaTime)
        }
        // first command encoder
        // update the particle emitters

        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        computeEncoder.setComputePipelineState(particlesPipelineState)
        let width = particlesPipelineState.threadExecutionWidth
        let threadsPerGroup = MTLSizeMake(width, 1, 1)

        for emitter in emitters {
            let threadsPerGrid = MTLSizeMake(emitter.particleCount, 1, 1)
            computeEncoder.setBuffer(emitter.particleBuffer, offset: 0, index: 0)
            var emitterUniforms = EmitterUniforms(gravity: emitter.gravity, airResistance: emitter.airResistance, deltaTime: deltaTime)
            computeEncoder.setBytes(&emitterUniforms, length: MemoryLayout<EmitterUniforms>.stride, index: 1)
            computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        }

        computeEncoder.endEncoding()

        // second command encoder, render encoder, displaying particles
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder.setRenderPipelineState(renderPipelineState)
        var size = float2(Float(view.drawableSize.width),
                          Float(view.drawableSize.height))
        renderEncoder.setVertexBytes(&size,
                                     length: MemoryLayout<float2>.stride,
                                     index: 0)
        for emitter in emitters {
            renderEncoder.setVertexBuffer(emitter.particleBuffer,
                                          offset: 0, index: 1)
            renderEncoder.setVertexBytes(&emitter.position,
                                         length: MemoryLayout<float3>.stride,
                                         index: 2)
            renderEncoder.setFragmentTexture(emitter.particleTexture, index: 0)
            renderEncoder.drawPrimitives(type: .point, vertexStart: 0,
                                         vertexCount: 1,
                                         instanceCount: emitter.currentParticles)
        }
        renderEncoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        emitters.removeAll()
        let snowEmitter = snow(size: size)
        snowEmitter.position = [0, Float(size.height), 0]
        emitters.append(snowEmitter)

        let fireEmitter = fire(size: size)
        fireEmitter.position = [0, -10, 0]
        emitters.append(fireEmitter)

        let experimentEmitter = experiment(size: size)
        experimentEmitter.position = [Float(size.width) / 2, Float(size.height) / 2, 0]
        emitters.append(experimentEmitter)
    }
}
