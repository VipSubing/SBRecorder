#import "GPUImageSBBlendFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageSBBlendFragmentShaderString = SHADER_STRING

(
 
 uniform sampler2D inputImageTexture;
 
 uniform sampler2D inputImageTexture2;
 
 uniform mediump int type;
 
 // varying highp vec2 anyTexCoord;
 
 varying highp vec2 textureCoordinate;
 
 void main ()
 
{
    
    mediump float alpha =texture2D(inputImageTexture2, textureCoordinate).a;
    
    mediump vec4 base = texture2D(inputImageTexture2,textureCoordinate);
    
    mediump vec4 overlay = texture2D(inputImageTexture, textureCoordinate);
    
    mediump float r = base.r*alpha + overlay.r*(1.0 - alpha);
    
    mediump float g = base.g*alpha + overlay.g*(1.0 - alpha);
    
    mediump float b = base.b*alpha + overlay.b*(1.0 - alpha);
    
    mediump float a =0.1;
    
    gl_FragColor = vec4(r, g, b,a);
    
}
 
 );

#else
NSString *const kGPUImageSBBlendFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform float mixturePercent;
 
 void main()
 {
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     gl_FragColor = mix(textureColor, textureColor2, mixturePercent);
 }
 );
#endif

@implementation GPUImageSBBlendFilter

@synthesize mix = _mix;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageSBBlendFragmentShaderString]))
    {
        return nil;
    }
    
    mixUniform = [filterProgram uniformIndex:@"mixturePercent"];
    self.mix = 0.5;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setMix:(CGFloat)newValue;
{
    _mix = newValue;
    
    [self setFloat:_mix forUniform:mixUniform program:filterProgram];
}

@end


