#import "GLProgram+CipheredResource.h"

@implementation GLProgram (CipheredResource)

- (id)initWithVertexShaderFilename:(NSString *)vertex cipheredFragmentShaderFilename:(NSString *)fragment key:(NSString *)key
{
	if (!(self = [super init])) {
		return nil;
	}

	program_ = glCreateProgram();
	vertShader_ = fragShader_ = 0;

	if (vertex) {
		NSString *fullname = [CCFileUtils fullPathFromRelativePath:vertex];
		NSData *data = [NSData dataWithContentsOfFile:fullname];
		if (![self compileShader:&vertShader_ type:GL_VERTEX_SHADER data:data]) {
			CCLOG(@"cocos2d: ERROR: Failed to compile vertex shader: %@", vertex);
		}
	}

	if (fragment) {
		NSString *fullname = [CCFileUtils fullPathFromRelativePath:fragment];
		NSData *data = [NSData dataWithContentsOfFile:fullname];
		NSError *error = nil;
		NSData *deciphered = [data decryptedAES256DataUsingKey:key error:&error];
		if (error == nil) {
			data = deciphered;
		}
		if (![self compileShader:&fragShader_ type:GL_FRAGMENT_SHADER data:data]) {
			CCLOG(@"cocos2d: ERROR: Failed to compile fragment shader: %@", fragment);
		}
	}

	if (vertShader_) {
		glAttachShader(program_, vertShader_);
	}
	if (fragShader_) {
		glAttachShader(program_, fragShader_);
	}
	return self;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type data:(NSData *)data
{
	GLint status;

	/* ARC will reap my data if I just assign GLchar *source = [data bytes] */
	GLchar source[[data length] + 1];
	memset(source, 0, [data length] + 1);
	[data getBytes:source];	
	
	const GLchar *p = source;

	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &p, NULL);
	glCompileShader(*shader);

	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);

	if (!status) {
		if (type == GL_VERTEX_SHADER) {
			CCLOG(@"cocos2d: %@: %@", file, [self vertexShaderLog]);
		} else {
			CCLOG(@"cocos2d: %@: %@", file, [self fragmentShaderLog]);
		}
	}
	return status == GL_TRUE;
}

@end
