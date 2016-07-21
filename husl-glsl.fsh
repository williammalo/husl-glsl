/*
HUSL-GLSL v1.0
HUSL is a human-friendly alternative to HSL. ( http://www.husl-colors.org )
GLSL port by William Malo ( https://github.com/williammalo )
Put this code in your fragment shader.
*/

float husl_intersectLineLine(vec2 line1, vec2 line2) {
    return (line1.y - line2.y) / (line2.x - line1.x);
}

float husl_distanceFromPole(vec2 point) {
    return sqrt(point.x*point.x + point.y*point.y);
}

float husl_lengthOfRayUntilIntersect(float theta, vec2 line) {
    float len = line.y / (sin(theta) - line.x * cos(theta));
    if (len < 0.0) {
        len=500.0;
    }
    return len;
}

float husl_maxSafeChromaForL(float L){
    mat3 m = mat3(
        vec3( 3.2409699419045214  , -1.5373831775700935 , -0.49861076029300328  ),
        vec3(-0.96924363628087983 ,  1.8759675015077207 ,  0.041555057407175613 ),
        vec3( 0.055630079696993609, -0.20397695888897657,  1.0569715142428786   )
    );
    float sub1 = pow(L + 16.0, 3.0) / 1560896.0;
    float sub2 = sub1 > 0.0088564516790356308 ? sub1 : L / 903.2962962962963;
      
    float rtop1 = (284517.0 * m[0][0] - 94839.0 * m[0][2]) * sub2;
    float rbottom = (632260.0 * m[0][2] - 126452.0 * m[0][1]) * sub2;
    float rtop2 = (838422.0 * m[0][2] + 769860.0 * m[0][1] + 731718.0 * m[0][0]) * L * sub2;

    vec2 bound0=vec2( rtop1 / (rbottom), (rtop2) / (rbottom) );
    vec2 bound1=vec2( rtop1 / (rbottom+126452.0), (rtop2-769860.0*L) / (rbottom+126452.0) );

    float gtop1 = (284517.0 * m[1][0] - 94839.0 * m[1][2]) * sub2;
    float gbottom = (632260.0 * m[1][2] - 126452.0 * m[1][1]) * sub2;
    float gtop2 = (838422.0 * m[1][2] + 769860.0 * m[1][1] + 731718.0 * m[1][0]) * L * sub2;

    vec2 bound2=vec2( gtop1 / (gbottom), (gtop2) / (gbottom) );
    vec2 bound3=vec2( gtop1 / (gbottom+126452.0), (gtop2-769860.0*L) / (gbottom+126452.0) );

    float btop1 = (284517.0 * m[2][0] - 94839.0 * m[2][2]) * sub2;
    float bbottom = (632260.0 * m[2][2] - 126452.0 * m[2][1]) * sub2;
    float btop2 = (838422.0 * m[2][2] + 769860.0 * m[2][1] + 731718.0 * m[2][0]) * L * sub2;

    vec2 bound4=vec2( btop1 / (bbottom), (btop2) / (bbottom) );
    vec2 bound5=vec2( btop1 / (bbottom+126452.0), (btop2-769860.0*L) / (bbottom+126452.0) );
    

    float x0 = husl_intersectLineLine(bound0, vec2(-1.0 / bound0.x, 0.0) );
    float length0=(husl_distanceFromPole( vec2(x0, bound0.y + x0 * bound0.x) ));

    float x1 = husl_intersectLineLine(bound1, vec2(-1.0 / bound1.x, 0.0) );
    float length1=(husl_distanceFromPole( vec2(x1, bound1.y + x1 * bound1.x) ));

    float x2 = husl_intersectLineLine(bound2, vec2(-1.0 / bound2.x, 0.0) );
    float length2=(husl_distanceFromPole( vec2(x2, bound2.y + x2 * bound2.x) ));
    
    float x3 = husl_intersectLineLine(bound3, vec2(-1.0 / bound3.x, 0.0) );
    float length3=(husl_distanceFromPole( vec2(x3, bound3.y + x3 * bound3.x) ));

    float x4 = husl_intersectLineLine(bound4, vec2(-1.0 / bound4.x, 0.0) );
    float length4=(husl_distanceFromPole( vec2(x4, bound4.y + x4 * bound4.x) ));

    float x5 = husl_intersectLineLine(bound5, vec2(-1.0 / bound5.x, 0.0) );
    float length5=(husl_distanceFromPole( vec2(x5, bound5.y + x5 * bound5.x) ));

    return min(length0,min(length1,min(length2,min(length3,min(length4,length5)))));
}



float husl_maxChromaForLH(float L, float H) {

    float hrad = radians(H);
    mat3 m = mat3(
      vec3(3.2409699419045214, -1.5373831775700935, -0.49861076029300328),
      vec3(-0.96924363628087983, 1.8759675015077207, 0.041555057407175613),
      vec3(0.055630079696993609, -0.20397695888897657, 1.0569715142428786)
    );
    float sub1 = pow(L + 16.0, 3.0) / 1560896.0;
    float sub2 = sub1 > 0.0088564516790356308 ? sub1 : L / 903.2962962962963;
      
    float rtop1 = (284517.0 * m[0][0] - 94839.0 * m[0][2]) * sub2;
    float rbottom = (632260.0 * m[0][2] - 126452.0 * m[0][1]) * sub2;
    float rtop2 = (838422.0 * m[0][2] + 769860.0 * m[0][1] + 731718.0 * m[0][0]) * L * sub2;

    vec2 bound0=vec2( rtop1 / (rbottom), (rtop2) / (rbottom) );
    vec2 bound1=vec2( rtop1 / (rbottom+126452.0), (rtop2-769860.0*L) / (rbottom+126452.0) );

    float gtop1 = (284517.0 * m[1][0] - 94839.0 * m[1][2]) * sub2;
    float gbottom = (632260.0 * m[1][2] - 126452.0 * m[1][1]) * sub2;
    float gtop2 = (838422.0 * m[1][2] + 769860.0 * m[1][1] + 731718.0 * m[1][0]) * L * sub2;

    vec2 bound2=vec2( gtop1 / (gbottom), (gtop2) / (gbottom) );
    vec2 bound3=vec2( gtop1 / (gbottom+126452.0), (gtop2-769860.0*L) / (gbottom+126452.0) );

    float btop1 = (284517.0 * m[2][0] - 94839.0 * m[2][2]) * sub2;
    float bbottom = (632260.0 * m[2][2] - 126452.0 * m[2][1]) * sub2;
    float btop2 = (838422.0 * m[2][2] + 769860.0 * m[2][1] + 731718.0 * m[2][0]) * L * sub2;

    vec2 bound4=vec2( btop1 / (bbottom), (btop2) / (bbottom) );
    vec2 bound5=vec2( btop1 / (bbottom+126452.0), (btop2-769860.0*L) / (bbottom+126452.0) );

    float length0=husl_lengthOfRayUntilIntersect(hrad, bound0);
    float length1=husl_lengthOfRayUntilIntersect(hrad, bound1);
    float length2=husl_lengthOfRayUntilIntersect(hrad, bound2);
    float length3=husl_lengthOfRayUntilIntersect(hrad, bound3);
    float length4=husl_lengthOfRayUntilIntersect(hrad, bound4);
    float length5=husl_lengthOfRayUntilIntersect(hrad, bound5);

    return min(length0,min(length1,min(length2,min(length3,min(length4,length5)))));
}

float husl_fromLinear(float c) {
    float newC = 0.0;
    if (c <= 0.0031308) {
      newC = 12.92 * c;
    } else {
      newC = 1.055 * pow(c, 1.0 / 2.4) - 0.055;
    }
    return newC;
}

float husl_toLinear(float c) {
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
    float R = husl_fromLinear(dot(vec3(3.2409699419045214, -1.5373831775700935, -0.49861076029300328), tuple.rgb));
    float G = husl_fromLinear(dot(vec3(-0.96924363628087983, 1.8759675015077207, 0.041555057407175613), tuple.rgb));
    float B = husl_fromLinear(dot(vec3(0.055630079696993609, -0.20397695888897657, 1.0569715142428786), tuple.rgb));
    return vec4(R, G, B, tuple.a);
}

vec4 rgb_to_xyz(vec4 tuple) {
    float R = tuple.r;
    float G = tuple.g;
    float B = tuple.b;
    vec3 rgbl = vec3(husl_toLinear(R),husl_toLinear(G),husl_toLinear(B));
    float X = dot(vec3(0.41239079926595948, 0.35758433938387796, 0.18048078840183429),rgbl);
    float Y = dot(vec3(0.21263900587151036, 0.71516867876775593, 0.072192315360733715),rgbl);
    float Z = dot(vec3(0.019330818715591851, 0.11919477979462599, 0.95053215224966058),rgbl);
    return vec4(X,Y,Z,tuple.a);
}

float husl_Y_to_L(float Y){
    float L = 0.0;
    if (Y <= 0.0088564516790356308) {
      L = Y * 903.2962962962963;
    } else {
      L = 116.0 * pow(Y, 1.0 / 3.0) - 16.0;
    }
    return L;
}

float husl_L_to_Y(float L) {
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

    float L = husl_Y_to_L(Y);

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

    float Y = husl_L_to_Y(L);
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

    float C = husl_maxChromaForLH(L, H) / 100.0 * S;

    return vec4(L, C, H, tuple.a);
}

vec4 lch_to_husl(vec4 tuple) {
    float L = tuple.r;
    float C = tuple.g;
    float H = tuple.b;

    float S = C / husl_maxChromaForLH(L, H) * 100.0;

    return vec4(H, S, L, tuple.a);
}

vec4 huslp_to_lch(vec4 tuple) {
    float H = tuple.r;
    float S = tuple.g;
    float L = tuple.b;

    float C = husl_maxSafeChromaForL(L) / 100.0 * S;

    return vec4(L, C, H, tuple.a);
}

vec4 lch_to_huslp(vec4 tuple) {
    float L = tuple.r;
    float C = tuple.g;
    float H = tuple.b;

    float S = C / husl_maxSafeChromaForL(L) * 100.0;
    
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