#version 120

uniform float adsk_result_w, adsk_result_h, adsk_result_frameratio;
vec2 res = vec2(adsk_result_w, adsk_result_h);

uniform float softness;

uniform int sides;
uniform float shape_aspect;
uniform float shape_size;
uniform vec2 shape_offset;



#define white vec4(1.0)
#define black vec4(0.0)

vec2 bary(vec2 pos, vec2 top, vec2 left,vec2  right)
{
	top += shape_offset;
	left += shape_offset;
	right += shape_offset;

	vec2 v0 = top - left;
    vec2 v1 = right - left;
    vec2 v2 = pos - left;

    float dot00 = dot(v0, v0);
    float dot01 = dot(v0, v1);
    float dot02 = dot(v0, v2);
    float dot11 = dot(v1, v1);
    float dot12 = dot(v1, v2);

    float invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01);
    float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

	return vec2(u,v);
}

mat2 get_matrix(float angle)
{

	float r = radians(angle);

    mat2 rotationMatrice = mat2(
								 cos(r),
								-sin(r),
								 sin(r),
								 cos(r)
							);	


	return rotationMatrice;
}

float draw_shape(vec2 st, vec2 center) 
{
	float col = 0.0;
	vec2 top = vec2(.5, .5 + shape_size * .5);
	
	vec2 shape[60];

	shape[0] = top;
	shape[0] -= center;
	shape[0].x *= adsk_result_frameratio;

	float a;

	for (int i = 1; i <= sides; i++) {
		a = 360 / float(sides) * float(i);

		shape[i] = shape[0] * get_matrix(a);

		shape[i].x /= adsk_result_frameratio;
		shape[i].x *= shape_aspect;
		shape[i] += center;

	}

	shape[0].x /= adsk_result_frameratio;
	shape[0] += center;

	if (sides < 3) {
		return 1.0;
	}

	float bot = 0.0;
	for (int i = 0; i < sides - 1 ; i++) {
		if (mod(sides, 2) != 0) {
			bot = ceil(float(sides) * .5);
			bot = shape[int(bot)].y;
		}

		/*
		shape[i].y -= bot;
		shape[i+1].y -= bot;
		shape[i+2].y -= bot;
		center.y -= bot;
		*/

		vec2 uv = bary(st, shape[i], shape[i+1], shape[i+2]);

		if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x + uv.y < 1.0) {
			col += 1.0;
		}

		col = clamp(col, 0.0, 1.0);

		if (sides > 4) {
			uv = bary(st, center, shape[i], shape[i+2]);

			if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x + uv.y < 1.0) {
				col += 1.0;
			}

		col = clamp(col, 0.0, 1.0);
		}
	}

	return col;
}


void main(void)
{
	vec2 st = gl_FragCoord.xy / vec2( adsk_result_w, adsk_result_h);

	float shape = draw_shape(st, vec2(.5));

	gl_FragColor = vec4(shape);
}
