#import "GLProgram.h"

@interface GLProgram (CipheredResource)

- (id)initWithVertexShaderFilename:(NSString *)vertex cipheredFragmentShaderFilename:(NSString *)fragment key:(NSString *)key;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type data:(NSData *)data;

@end
