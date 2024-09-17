shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // 获取当前像素的颜色
    vec4 color = texture(TEXTURE, UV);
    
    // 计算颜色的亮度（使用加权平均法，接近人眼对颜色的感知）
    float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    // 如果颜色较暗（亮度较低），让其变得更黑
    // 你可以调整这个阈值来控制何时开始变黑
    if (brightness < 0.9) {
        color.rgb *= brightness; // 根据亮度调暗颜色
    }
    
    // 输出调整后的颜色
    COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
