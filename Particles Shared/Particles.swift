import CoreGraphics
import simd
import UIKit

extension Renderer {
    func fire(size: CGSize) -> Emitter {
        let emitter = Emitter()
        emitter.particleCount = 5000
        emitter.particleTexture = Emitter.loadTexture(imageName: "fire")!
        emitter.birthRate = 5
        var descriptor = ParticleDescriptor()
        descriptor.position.x = Float(size.width) / 2 - 90
        descriptor.positionXRange = 0...180
        descriptor.direction = Float.pi / 2
        descriptor.directionRange = -0.5...0.5
        descriptor.speed = 300
        descriptor.pointSize = 80
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.5...1.0
        descriptor.endScaleRange = 0...0
        descriptor.life = 30
        descriptor.lifeRange = -0.5...0.5
        descriptor.color = float4(1.0, 0.24, 0.45, 0.5);
        emitter.particleDescriptor = descriptor
        emitter.gravity = float3(0, -40.8, 0)
        return emitter
    }

    func snow(size: CGSize) -> Emitter {
        let emitter = Emitter()
        emitter.particleCount = 1000
        emitter.birthRate = 3
        emitter.birthDelay = 0.333
        emitter.particleTexture = Emitter.loadTexture(imageName: "snowflake")!
        var descriptor = ParticleDescriptor()
        descriptor.position.x = 0
        descriptor.positionXRange = 0...Float(size.width)
        descriptor.direction = -.pi / 2
        descriptor.speedRange =  120...360
        descriptor.pointSizeRange = 80 * 0.5...80
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.01...0.3
        descriptor.life = 8.5
        descriptor.color = float4(1.0);
        emitter.particleDescriptor = descriptor
        return emitter
    }

    func experiment(size: CGSize) -> Emitter {
        let emitter = Emitter()
        emitter.particleCount = 1200
        emitter.particleTexture = Emitter.loadTexture(imageName: "fire")!
        emitter.birthRate = 5
        var descriptor = ParticleDescriptor()
        descriptor.position.x = 0
        descriptor.positionXRange = 0...180
        descriptor.positionYRange = 0...180
        descriptor.direction = 0
        descriptor.directionRange = (0...2 * Float.pi)
        descriptor.speed = 60
        descriptor.pointSize = 30
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.5...1.0
        descriptor.endScaleRange = 0...0
        descriptor.life = 2
        descriptor.lifeRange = -0.8...1.2
        descriptor.color = float4(0.1, 0.4, 0.8, 0.5);
        emitter.particleDescriptor = descriptor
        return emitter
    }
}
