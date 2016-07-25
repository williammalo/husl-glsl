/*
HUSL-GLSL v3.0
HUSL is a human-friendly alternative to HSL. ( http://www.husl-colors.org )
GLSL port by William Malo ( https://github.com/williammalo )
Put this code in your fragment shader.
*/

vec3 husl_intersectLineLine(vec3 line1x, vec3 line1y, vec3 line2x, vec3 line2y) {
    return (line1y - line2y) / (line2x - line1x);
}

vec3 husl_distanceFromPole(vec3 pointx,vec3 pointy) {
    return sqrt(pointx*pointx + pointy*pointy);
}

vec3 husl_lengthOfRayUntilIntersect(float theta, vec3 x, vec3 y) {
    vec3 len = y / (sin(theta) - x * cos(theta));
    if (len.r < 0.0) {len.r=1000.0;}
    if (len.g < 0.0) {len.g=1000.0;}
    if (len.b < 0.0) {len.b=1000.0;}
    return len;
}

float husl_maxSafeChromaForL(float L){
    mat3 m2 = mat3(
        vec3( 3.2409699419045214  ,-0.96924363628087983 , 0.055630079696993609),
        vec3(-1.5373831775700935  , 1.8759675015077207  ,-0.20397695888897657 ),
        vec3(-0.49861076029300328 , 0.041555057407175613, 1.0569715142428786  )
    );
    float sub1 = pow(L + 16.0, 3.0) / 1560896.0;
    float sub2 = sub1 > 0.0088564516790356308 ? sub1 : L / 903.2962962962963;

    vec3 top1 = ( 284517.0 * m2[0] - 94839.0 * m2[2]) * sub2;
    vec3 bottom = (632260.0 * m2[2] - 126452.0 * m2[1]) * sub2;
    vec3 top2 = (838422.0 * m2[2] + 769860.0 * m2[1] + 731718.0 * m2[0]) * L * sub2;

    vec3 bounds0x = top1 / bottom;
    vec3 bounds0y = top2 / bottom;

    vec3 bounds1x = top1 / (bottom+126452.0);
    vec3 bounds1y = (top2-769860.0*L) / (bottom+126452.0);

    vec3 xs0 = husl_intersectLineLine(bounds0x, bounds0y, -1.0/bounds0x, vec3(0.0) );
    vec3 xs1 = husl_intersectLineLine(bounds1x, bounds1y, -1.0/bounds1x, vec3(0.0) );

    vec3 lengths0 = husl_distanceFromPole( xs0, bounds0y + xs0 * bounds0x );
    vec3 lengths1 = husl_distanceFromPole( xs0, bounds0y + xs0 * bounds0x );

    return  min(lengths0.r,
            min(lengths1.r,
            min(lengths0.g,
            min(lengths1.g,
            min(lengths0.b,
                lengths1.b)))));
}

float husl_maxChromaForLH(float L, float H) {

    float hrad = radians(H);

    mat3 m2 = mat3(
        vec3( 3.2409699419045214  ,-0.96924363628087983 , 0.055630079696993609),
        vec3(-1.5373831775700935  , 1.8759675015077207  ,-0.20397695888897657 ),
        vec3(-0.49861076029300328 , 0.041555057407175613, 1.0569715142428786  )
    );
    float sub1 = pow(L + 16.0, 3.0) / 1560896.0;
    float sub2 = sub1 > 0.0088564516790356308 ? sub1 : L / 903.2962962962963;

    vec3 top1 = ( 284517.0 * m2[0] - 94839.0 * m2[2]) * sub2;
    vec3 bottom = (632260.0 * m2[2] - 126452.0 * m2[1]) * sub2;
    vec3 top2 = (838422.0 * m2[2] + 769860.0 * m2[1] + 731718.0 * m2[0]) * L * sub2;

    vec3 bound0x = top1 / bottom;
    vec3 bound0y = top2 / bottom;

    vec3 bound1x = top1 / (bottom+126452.0);
    vec3 bound1y = (top2-769860.0*L) / (bottom+126452.0);

    vec3 lengths0 = husl_lengthOfRayUntilIntersect(hrad, bound0x, bound0y );
    vec3 lengths1 = husl_lengthOfRayUntilIntersect(hrad, bound1x, bound1y );

    return  min(lengths0.r,
            min(lengths1.r,
            min(lengths0.g,
            min(lengths1.g,
            min(lengths0.b,
                lengths1.b)))));
}

float husl_fromLinear(float c) {
    return c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1.0 / 2.4) - 0.055;
}

float husl_toLinear(float c) {
    return c > 0.04045 ? pow((c + 0.055) / (1.0 + 0.055), 2.4) : c / 12.92;
}

vec3 husl_toLinear(vec3 c) {
    return vec3( husl_toLinear(c.r), husl_toLinear(c.g), husl_toLinear(c.b) );
}

float husl_yToL(float Y){
    return Y <= 0.0088564516790356308 ? Y * 903.2962962962963 : 116.0 * pow(Y, 1.0 / 3.0) - 16.0;
}

float husl_lToY(float L) {
    return L <= 8.0 ? L / 903.2962962962963 : pow((L + 16.0) / 116.0, 3.0);
}

vec4 xyzToRgb(vec4 tuple) {
    return vec4(
        husl_fromLinear(dot(vec3( 3.2409699419045214  ,-1.5373831775700935 ,-0.49861076029300328 ), tuple.rgb )),//r
        husl_fromLinear(dot(vec3(-0.96924363628087983 , 1.8759675015077207 , 0.041555057407175613), tuple.rgb )),//g
        husl_fromLinear(dot(vec3( 0.055630079696993609,-0.20397695888897657, 1.0569715142428786  ), tuple.rgb )),//b
        tuple.a
    );
}

vec4 rgbToXyz(vec4 tuple) {
    vec3 rgbl = husl_toLinear(tuple.rgb);
    return vec4(
        dot(vec3(0.41239079926595948 , 0.35758433938387796, 0.18048078840183429 ), rgbl ),//x
        dot(vec3(0.21263900587151036 , 0.71516867876775593, 0.072192315360733715), rgbl ),//y
        dot(vec3(0.019330818715591851, 0.11919477979462599, 0.95053215224966058 ), rgbl ),//z
        tuple.a
    );
}

vec4 xyzToLuv(vec4 tuple){
    float X = tuple.r;
    float Y = tuple.g;
    float Z = tuple.b;

    float L = husl_yToL(Y);

    float varU = (4.0 * X) / (X + (15.0 * Y) + (3.0 * Z));
    float varV = (9.0 * Y) / (X + (15.0 * Y) + (3.0 * Z));

    float U = 13.0 * L * (varU - 0.19783000664283681);
    float V = 13.0 * L * (varV - 0.468319994938791);

    return vec4(L, U, V, tuple.a);
}

vec4 luvToXyz(vec4 tuple) {

    float L = tuple.r;
    float U = tuple.g;
    float V = tuple.b;

    float varU = U / (13.0 * L) + 0.19783000664283681;
    float varV = V / (13.0 * L) + 0.468319994938791;

    float Y = husl_lToY(L);
    float X = 0.0 - (9.0 * Y * varU) / ((varU - 4.0) * varV - varU * varV);
    float Z = (9.0 * Y - (15.0 * varV * Y) - (varV * X)) / (3.0 * varV);

    return vec4(X, Y, Z,tuple.a);
}

vec4 luvToLch(vec4 tuple) {

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

vec4 lchToLuv(vec4 tuple) {
    float hrad = radians(tuple.b);
    return vec4(
        tuple.r,
        cos(hrad) * tuple.g,
        sin(hrad) * tuple.g,
        tuple.a
    );
}

vec4 huslToLch(vec4 tuple) {
    tuple.g *= husl_maxChromaForLH(tuple.b, tuple.r) / 100.0;
    return tuple.bgra;
}

vec4 lchToHusl(vec4 tuple) {
    tuple.g /= husl_maxChromaForLH(tuple.r, tuple.b) * 100.0;
    return tuple.bgra;
}

vec4 huslpToLch(vec4 tuple) {
    tuple.g *= husl_maxSafeChromaForL(tuple.b) / 100.0;
    return tuple.bgra;
}

vec4 lchToHuslp(vec4 tuple) {
    tuple.g /= husl_maxSafeChromaForL(tuple.r) * 100.0;
    return tuple.bgra;
}

vec4 lchToRgb(vec4 tuple) {
    return xyzToRgb(luvToXyz(lchToLuv(tuple)));
}

vec4 rgbToLch(vec4 tuple) {
    return luvToLch(xyzToLuv(rgbToXyz(tuple)));
}

vec4 huslToRgb(vec4 tuple) {
    return lchToRgb(huslToLch(tuple));
}

vec4 rgbToHusl(vec4 tuple) {
    return lchToHusl(rgbToLch(tuple));
}

vec4 huslpToRgb(vec4 tuple) {
    return lchToRgb(huslpToLch(tuple));
}

vec4 rgbToHuslp(vec4 tuple) {
    return lchToHuslp(rgbToLch(tuple));
}

vec4 luvToRgb(vec4 tuple){
    return xyzToRgb(luvToXyz(tuple));
}

// allow vec3's
vec3   xyzToRgb(vec3 tuple) {return   xyzToRgb(vec4(tuple,1.0)).rgb;}
vec3   rgbToXyz(vec3 tuple) {return   rgbToXyz(vec4(tuple,1.0)).rgb;}
vec3   xyzToLuv(vec3 tuple) {return   xyzToLuv(vec4(tuple,1.0)).rgb;}
vec3   luvToXyz(vec3 tuple) {return   luvToXyz(vec4(tuple,1.0)).rgb;}
vec3   luvToLch(vec3 tuple) {return   luvToLch(vec4(tuple,1.0)).rgb;}
vec3   lchToLuv(vec3 tuple) {return   lchToLuv(vec4(tuple,1.0)).rgb;}
vec3  huslToLch(vec3 tuple) {return  huslToLch(vec4(tuple,1.0)).rgb;}
vec3  lchToHusl(vec3 tuple) {return  lchToHusl(vec4(tuple,1.0)).rgb;}
vec3 huslpToLch(vec3 tuple) {return huslpToLch(vec4(tuple,1.0)).rgb;}
vec3 lchToHuslp(vec3 tuple) {return lchToHuslp(vec4(tuple,1.0)).rgb;}
vec3   lchToRgb(vec3 tuple) {return   lchToRgb(vec4(tuple,1.0)).rgb;}
vec3   rgbToLch(vec3 tuple) {return   rgbToLch(vec4(tuple,1.0)).rgb;}
vec3  huslToRgb(vec3 tuple) {return  huslToRgb(vec4(tuple,1.0)).rgb;}
vec3  rgbToHusl(vec3 tuple) {return  rgbToHusl(vec4(tuple,1.0)).rgb;}
vec3 huslpToRgb(vec3 tuple) {return huslpToRgb(vec4(tuple,1.0)).rgb;}
vec3 rgbToHuslp(vec3 tuple) {return rgbToHuslp(vec4(tuple,1.0)).rgb;}
vec3   luvToRgb(vec3 tuple) {return   luvToRgb(vec4(tuple,1.0)).rgb;}
// allow 3 floats
vec3   xyzToRgb(float x, float y, float z) {return   xyzToRgb( vec3(x,y,z) );}
vec3   rgbToXyz(float x, float y, float z) {return   rgbToXyz( vec3(x,y,z) );}
vec3   xyzToLuv(float x, float y, float z) {return   xyzToLuv( vec3(x,y,z) );}
vec3   luvToXyz(float x, float y, float z) {return   luvToXyz( vec3(x,y,z) );}
vec3   luvToLch(float x, float y, float z) {return   luvToLch( vec3(x,y,z) );}
vec3   lchToLuv(float x, float y, float z) {return   lchToLuv( vec3(x,y,z) );}
vec3  huslToLch(float x, float y, float z) {return  huslToLch( vec3(x,y,z) );}
vec3  lchToHusl(float x, float y, float z) {return  lchToHusl( vec3(x,y,z) );}
vec3 huslpToLch(float x, float y, float z) {return huslpToLch( vec3(x,y,z) );}
vec3 lchToHuslp(float x, float y, float z) {return lchToHuslp( vec3(x,y,z) );}
vec3   lchToRgb(float x, float y, float z) {return   lchToRgb( vec3(x,y,z) );}
vec3   rgbToLch(float x, float y, float z) {return   rgbToLch( vec3(x,y,z) );}
vec3  huslToRgb(float x, float y, float z) {return  huslToRgb( vec3(x,y,z) );}
vec3  rgbToHusl(float x, float y, float z) {return  rgbToHusl( vec3(x,y,z) );}
vec3 huslpToRgb(float x, float y, float z) {return huslpToRgb( vec3(x,y,z) );}
vec3 rgbToHuslp(float x, float y, float z) {return rgbToHuslp( vec3(x,y,z) );}
vec3   luvToRgb(float x, float y, float z) {return   luvToRgb( vec3(x,y,z) );}
// allow 4 floats
vec4   xyzToRgb(float x, float y, float z, float a) {return   xyzToRgb( vec4(x,y,z,a) );}
vec4   rgbToXyz(float x, float y, float z, float a) {return   rgbToXyz( vec4(x,y,z,a) );}
vec4   xyzToLuv(float x, float y, float z, float a) {return   xyzToLuv( vec4(x,y,z,a) );}
vec4   luvToXyz(float x, float y, float z, float a) {return   luvToXyz( vec4(x,y,z,a) );}
vec4   luvToLch(float x, float y, float z, float a) {return   luvToLch( vec4(x,y,z,a) );}
vec4   lchToLuv(float x, float y, float z, float a) {return   lchToLuv( vec4(x,y,z,a) );}
vec4  huslToLch(float x, float y, float z, float a) {return  huslToLch( vec4(x,y,z,a) );}
vec4  lchToHusl(float x, float y, float z, float a) {return  lchToHusl( vec4(x,y,z,a) );}
vec4 huslpToLch(float x, float y, float z, float a) {return huslpToLch( vec4(x,y,z,a) );}
vec4 lchToHuslp(float x, float y, float z, float a) {return lchToHuslp( vec4(x,y,z,a) );}
vec4   lchToRgb(float x, float y, float z, float a) {return   lchToRgb( vec4(x,y,z,a) );}
vec4   rgbToLch(float x, float y, float z, float a) {return   rgbToLch( vec4(x,y,z,a) );}
vec4  huslToRgb(float x, float y, float z, float a) {return  huslToRgb( vec4(x,y,z,a) );}
vec4  rgbToHusl(float x, float y, float z, float a) {return  rgbToHusl( vec4(x,y,z,a) );}
vec4 huslpToRgb(float x, float y, float z, float a) {return huslpToRgb( vec4(x,y,z,a) );}
vec4 rgbToHuslp(float x, float y, float z, float a) {return rgbToHuslp( vec4(x,y,z,a) );}
vec4   luvToRgb(float x, float y, float z, float a) {return   luvToRgb( vec4(x,y,z,a) );}

/*
END HUSL-GLSL
*/