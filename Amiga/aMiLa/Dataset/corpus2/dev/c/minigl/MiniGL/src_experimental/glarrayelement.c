
//Note:	GLEnd should wrap to some proper drawfuncs
//		drawfuncs would handle texcoords and colors
//		after culling

void GLArrayElement(GLcontext context, GLint i)
{
	int thisvert;
	MGLVertex *v;

	thisvert = context->VertexBufferPointer;

	//store pos for eventual colors and texcoords
	context->ElementIndex[thisvert] = i;

	//check for locked arrays
	if(context->ArrayPointer.transformed == GL_TRUE)
	{
		thisvert += context->ArrayPointer.lockfirst + context->ArrayPointer.locksize;

		v = &(context->VertexBuffer[thisvert]);

		if(Clip_Volume_Bypass == GL_FALSE && v->outcode == 0)
		{
			v->v.x = context->VertexBuffer[i].v.x;
			v->v.y = context->VertexBuffer[i].v.y;
			v->v.z = context->VertexBuffer[i].v.z;
			v->v.w = context->VertexBuffer[i].v.w;

			v->bx = context->VertexBuffer[i].bx;
			v->by = context->VertexBuffer[i].by;
			v->bz = context->VertexBuffer[i].bz;
			v->bw = context->VertexBuffer[i].bw;
		}
		else
		{
			v->bx = context->VertexBuffer[i].bx;
			v->by = context->VertexBuffer[i].by;
			v->bz = context->VertexBuffer[i].bz;
			v->bw = context->VertexBuffer[i].bw;
		}

	}
	else
	{
		GLfloat *vert;
		vert = (GLfloat *)(context->ArrayPointer.verts + i * context->ArrayPointer.vertexstride);

		v = &(context->VertexBuffer[thisvert]);

		v->bx = vert[0];
		v->by = vert[1];
		v->bz = vert[2];
		v->bw = 1.0;
	}

	context->VertexBufferPointer++;
}