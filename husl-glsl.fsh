/*
HUSL-GLSL v0.0
HUSL is a human-friendly alternative to HSL. ( http://www.husl-colors.org )
GLSL port by William Malo ( https://github.com/williammalo )
Put this code in your fragment shader. Requires lookup table sampler2D called "huslLookupTable"
*/

float maxChromaForLH( float L, float H ){
    vec4 c = texture2D(huslLookupTable, vec2(H/512.0,L/512.0));
    return (c.r+c.g)*127.5;
}

float maxSafeChromaForL(float L){
    return texture2D(huslLookupTable, vec2(0.25,L/512.0)).b*127.5;
}

float maxChromaForL(float L){
    vec4 c = texture2D(huslLookupTable, vec2(0.25,(L+101.0)/512.0));
    return (c.r+c.g+c.b)*(255.0/3.0);
}

float fromLinear(float c) {
    float newC = 0.0;
    if (c <= 0.0031308) {
      newC = 12.92 * c;
    } else {
      newC = 1.055 * pow(c, 1.0 / 2.4) - 0.055;
    }
    return newC;
}

float toLinear(float c) {
    float a = 0.055;
    float newC = 0.0;
    if (c > 0.04045) {
        newC = pow((c + a) / (1.0 + a), 2.4);
    } else {
        newC = c / 12.92;
    }
    return newC;
}

vec4 xyz_to_rgb(vec4 tuple) {
    float R = fromLinear(dot(vec3(3.2409699419045214, -1.5373831775700935, -0.49861076029300328), tuple.rgb));
    float G = fromLinear(dot(vec3(-0.96924363628087983, 1.8759675015077207, 0.041555057407175613), tuple.rgb));
    float B = fromLinear(dot(vec3(0.055630079696993609, -0.20397695888897657, 1.0569715142428786), tuple.rgb));
    return vec4(R, G, B, tuple.a);
}

vec4 rgb_to_xyz(vec4 tuple) {
    float R = tuple.r;
    float G = tuple.g;
    float B = tuple.b;
    vec3 rgbl = vec3(toLinear(R),toLinear(G),toLinear(B));
    float X = dot(vec3(0.41239079926595948, 0.35758433938387796, 0.18048078840183429),rgbl);
    float Y = dot(vec3(0.21263900587151036, 0.71516867876775593, 0.072192315360733715),rgbl);
    float Z = dot(vec3(0.019330818715591851, 0.11919477979462599, 0.95053215224966058),rgbl);
    return vec4(X,Y,Z,tuple.a);
}

float Y_to_L(float Y){
    float L = 0.0;
    if (Y <= 0.0088564516790356308) {
      L = Y * 903.2962962962963;
    } else {
      L = 116.0 * pow(Y, 1.0 / 3.0) - 16.0;
    }
    return L;
}

float L_to_Y(float L) {
    float Y = 0.0;
    if (L <= 8.0) {
      Y = L / 903.2962962962963;
    } else {
      Y = pow((L + 16.0) / 116.0, 3.0);
    }
    return Y;
}

vec4 xyz_to_luv(vec4 tuple){
    float X = tuple.r;
    float Y = tuple.g;
    float Z = tuple.b;

    float L = Y_to_L(Y);

    float varU = (4.0 * X) / (X + (15.0 * Y) + (3.0 * Z));
    float varV = (9.0 * Y) / (X + (15.0 * Y) + (3.0 * Z));

    float U = 13.0 * L * (varU - 0.19783000664283681);
    float V = 13.0 * L * (varV - 0.468319994938791);

    return vec4(L, U, V, tuple.a);
}

vec4 luv_to_xyz(vec4 tuple) {

    float L = tuple.r;
    float U = tuple.g;
    float V = tuple.b;

    float varU = U / (13.0 * L) + 0.19783000664283681;
    float varV = V / (13.0 * L) + 0.468319994938791;

    float Y = L_to_Y(L);
    float X = 0.0 - (9.0 * Y * varU) / ((varU - 4.0) * varV - varU * varV);
    float Z = (9.0 * Y - (15.0 * varV * Y) - (varV * X)) / (3.0 * varV);

    return vec4(X, Y, Z,tuple.a);
}

vec4 luv_to_lch(vec4 tuple) {

    float L = tuple.r;
    float U = tuple.g;
    float V = tuple.b;

    float C = sqrt(pow(U, 2.0) + pow(V, 2.0));
    float H = degrees(atan(V, U));
    if (H < 0.0) {
        H = 360.0 + H;
    }
    
    return vec4(L, C, H, tuple.a);
}

vec4 lch_to_luv(vec4 color) {
    float a = cos(radians(color.b)) * color.g;
    float b = sin(radians(color.b)) * color.g;

    return vec4(color.r, a, b, color.a);
}

vec4 husl_to_lch(vec4 tuple) {
    float H = tuple.r;
    float S = tuple.g;
    float L = tuple.b;

    float C = maxChromaForLH(L, H) / 100.0 * S;

    return vec4(L, C, H, tuple.a);
}

vec4 lch_to_husl(vec4 tuple) {
    float L = tuple.r;
    float C = tuple.g;
    float H = tuple.b;

    float S = C / maxChromaForLH(L, H) * 100.0;

    return vec4(H, S, L, tuple.a);
}

vec4 huslp_to_lch(vec4 tuple) {
    float H = tuple.r;
    float S = tuple.g;
    float L = tuple.b;

    float C = maxSafeChromaForL(L) / 100.0 * S;

    return vec4(L, C, H, tuple.a);
}

vec4 lch_to_huslp(vec4 tuple) {
    float L = tuple.r;
    float C = tuple.g;
    float H = tuple.b;

    float S = C / maxSafeChromaForL(L) * 100.0;
    
    return vec4(H, S, L, tuple.a);
}

vec4 lch_to_rgb(vec4 tuple) {
    return xyz_to_rgb(luv_to_xyz(lch_to_luv(tuple)));
}

vec4 rgb_to_lch(vec4 tuple) {
    return luv_to_lch(xyz_to_luv(rgb_to_xyz(tuple)));
}

vec4 husl_to_rgb(vec4 tuple) {
    return lch_to_rgb(husl_to_lch(tuple));
}

vec4 rgb_to_husl(vec4 tuple) {
    return lch_to_husl(rgb_to_lch(tuple));
}

vec4 huslp_to_rgb(vec4 tuple) {
    return lch_to_rgb(huslp_to_lch(tuple));
}

vec4 rgb_to_huslp(vec4 tuple) {
    return lch_to_huslp(rgb_to_lch(tuple));
}

vec4 luv_to_rgb(vec4 tuple){
    return xyz_to_rgb(luv_to_xyz(tuple));
}

/*
END HUSL-GLSL
*/