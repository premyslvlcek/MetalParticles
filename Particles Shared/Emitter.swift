import MetalKit

struct Particle {
    var startPosition: float3
    var startVelocity: float3
    var position: float3
    var velocity: float3
    var color: float4
    var age: Float
    var life: Float
    var size: Float
    var scale: Float = 1.0
    var startScale: Float = 1.0
    var endScale: Float = 1.0
}

struct EmitterUniforms {
    var gravity: float3
    var airResistance: Float
    var deltaTime: Float
};

struct ParticleDescriptor {
    var position = float3(repeating: 0)
    var positionXRange: ClosedRange<Float> = 0...0
    var positionYRange: ClosedRange<Float> = 0...0
    var positionZRange: ClosedRange<Float> = 0...0
    var direction: Float = 0
    var directionRange: ClosedRange<Float> = 0...0
    var speed: Float = 0
    var speedRange: ClosedRange<Float> = 0...0
    var pointSize: Float = 80
    var pointSizeRange: ClosedRange<Float> = 0...0
    var startScale: Float = 0
    var startScaleRange: ClosedRange<Float> = 1...1
    var endScale: Float = 0
    var endScaleRange: ClosedRange<Float>?
    var life: Float = 0
    var lifeRange: ClosedRange<Float> = 1...1
    var color = float4(repeating: 0)
}

class Emitter {
    var gravity: float3 = float3(0, 0, 0)
    var airResistance: Float = 0
    var position: float3 = [0, 0, 0]

    var currentParticles = 0
    var particleCount: Int = 0 {
        didSet {
            let bufferSize = MemoryLayout<Particle>.stride * particleCount
            particleBuffer = Renderer.device.makeBuffer(length: bufferSize)!
        }
    }

    var birthRate = 0
    var birthDelay: Float = 0 {
        didSet {
            birthTimer = birthDelay
        }
    }
    private var birthTimer: Float = 0

    var particleTexture: MTLTexture!
    var particleBuffer: MTLBuffer?

    var particleDescriptor: ParticleDescriptor?

    func emit(deltaTime: Float) {
        if currentParticles >= particleCount {
            return
        }

        guard let particleBuffer = particleBuffer, let pd = particleDescriptor else {
                return
        }

        birthTimer += deltaTime

        if birthTimer < birthDelay {
            return
        }

        birthTimer = 0
        var pointer = particleBuffer.contents().bindMemory(to: Particle.self,capacity: particleCount)
        pointer = pointer.advanced(by: currentParticles)
        for _ in 0..<birthRate {
            let positionX = pd.position.x + .random(in: pd.positionXRange)
            let positionY = pd.position.y + .random(in: pd.positionYRange)
            let positionZ = pd.position.z + .random(in: pd.positionZRange)

            pointer.pointee.position = [positionX, positionY, positionZ]
            pointer.pointee.startPosition = pointer.pointee.position

            pointer.pointee.size = pd.pointSize + .random(in: pd.pointSizeRange)
            let direction = pd.direction + .random(in: pd.directionRange)
            let speed = pd.speed + .random(in: pd.speedRange)
            let velocity = float3(cos(direction), sin(direction), 0) * speed
            pointer.pointee.velocity = velocity
            pointer.pointee.startVelocity = pointer.pointee.velocity
            pointer.pointee.scale = pd.startScale + .random(in: pd.startScaleRange)
            pointer.pointee.startScale = pointer.pointee.scale

            if let range = pd.endScaleRange {
                pointer.pointee.endScale = pd.endScale + .random(in: range)
            } else {
                pointer.pointee.endScale = pointer.pointee.startScale
            }

            pointer.pointee.age = 0
            pointer.pointee.life = pd.life + .random(in: pd.lifeRange)
            pointer.pointee.color = pd.color

            pointer = pointer.advanced(by: 1)
        }
        currentParticles += birthRate
    }

    static func loadTexture(imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        var texture: MTLTexture?
        let textureLoaderOptions: [MTKTextureLoader.Option : Any]
        textureLoaderOptions = [.origin: MTKTextureLoader.Origin.bottomLeft, .SRGB: false]

        do {
            let fileExtension: String? = URL(fileURLWithPath: imageName).pathExtension.count == 0 ? "png" : nil
            if let url: URL = Bundle.main.url(forResource: imageName, withExtension: fileExtension) {
                texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
            } else {
                print("Failed to load \(imageName)")
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return texture
    }
}
