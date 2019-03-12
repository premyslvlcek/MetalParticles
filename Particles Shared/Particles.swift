import CoreGraphics
import simd
import UIKit

extension Renderer {
    func fire(size: CGSize) -> Emitter {
        let emitter = Emitter()
        emitter.particleCount = 1200
        emitter.particleTexture = Emitter.loadTexture(imageName: "fire")!
        emitter.birthRate = 5
        var descriptor = ParticleDescriptor()
        descriptor.position.x = Float(size.width) / 2 - 90
        descriptor.positionXRange = 0...180
        descriptor.direction = Float.pi / 2
        descriptor.directionRange = -0.3...0.3
        descriptor.speed = 3
        descriptor.pointSize = 80
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.5...1.0
        descriptor.endScaleRange = 0...0
        descriptor.life = 180
        descriptor.lifeRange = -50...70
        descriptor.color = float4(1.0, 0.392, 0.1, 0.5);
        emitter.particleDescriptor = descriptor
        emitter.gravity = float2(0, -9.8)
        emitter.airResistance = 1.8
        return emitter
    }

    func snow(size: CGSize) -> Emitter {
        let emitter = Emitter()
        emitter.particleCount = 1000
        emitter.birthRate = 3
        emitter.birthDelay = 20
        emitter.particleTexture = Emitter.loadTexture(imageName: "snowflake")!
        var descriptor = ParticleDescriptor()
        descriptor.position.x = 0
        descriptor.positionXRange = 0...Float(size.width)
        descriptor.direction = -.pi / 2
        descriptor.speedRange =  2...6
        descriptor.pointSizeRange = 80 * 0.5...80
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.01...0.3
        descriptor.life = 500
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
        descriptor.speed = 1
        descriptor.pointSize = 30
        descriptor.startScale = 0
        descriptor.startScaleRange = 0.5...1.0
        descriptor.endScaleRange = 0...0
        descriptor.life = 120
        descriptor.lifeRange = -50...70
        descriptor.color = float4(0.1, 0.4, 0.8, 0.5);
        emitter.particleDescriptor = descriptor
        return emitter
    }
}
