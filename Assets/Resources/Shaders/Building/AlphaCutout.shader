// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Building/Alpha Cutout" {
	Properties {
		// Textures
		_MainTex ("Base (RGB)", 2D) = "white" {}
		// Gradient
		_GradientColor ("Gradient Color", Color) = (1, 1, 1, 1)
		_GradientStart ("Gradient Start", Float) = 0
		_GradientEnd ("Gradient End", Float) = 1
		_GradientHeight ("Gradient Height", Float) = 0
		_Cutoff ("Alpha Cutoff", Range (0,1)) = 0.5
	}
	SubShader {
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" }
	  
		CGPROGRAM
		#pragma surface _SurfaceShader Lambert vertex:_VertexShader finalcolor:_FinalColor alphatest:_Cutoff
		//#pragma surface _SurfaceShader Lambert vertex:_VertexShader alphatest:_Cutoff

		struct Input {
			fixed4 color: COLOR;
			half height;
			half fog;
			float2 uv_MainTex;
		};
	  
		sampler2D _MainTex;
		fixed4 _GradientColor;
		float _GradientStart;
		float _GradientEnd;
		float _GradientHeight;
	    uniform half4 unity_FogStart;
	    uniform half4 unity_FogEnd;
		
		//////////////////////////////////////////////////
		void _VertexShader (inout appdata_full v, out Input data) {
			UNITY_INITIALIZE_OUTPUT(Input, data);
			float dist = length(mul(UNITY_MATRIX_MV, v.vertex).xyz);
			float diff = unity_FogEnd.x - unity_FogStart.x;
			float invDiff = 1.0f / diff;
			data.fog = clamp ((unity_FogEnd.x - dist) * invDiff, 0.0, 1.0);
			data.height = mul(unity_ObjectToWorld, v.vertex).y;
		}
		
		//////////////////////////////////////////////////
	    fixed3 ApplyGradient(fixed3 color, float height)
	    {
	    	return lerp(_GradientColor.rgb, color, lerp(_GradientStart, _GradientEnd, clamp(height, 0, _GradientHeight) / _GradientHeight));
	    }
	  	
	  	//////////////////////////////////////////////////
		void _SurfaceShader (Input IN, inout SurfaceOutput o) {
			fixed4 texel = tex2D (_MainTex, IN.uv_MainTex);
			fixed3 albedo = texel.rgb * IN.color.rgb;
			o.Albedo = fixed3(1,0,0); //ApplyGradient(albedo, IN.height);
			o.Alpha = texel.a;
		}
		
		void _FinalColor (Input IN, SurfaceOutput o, inout fixed4 color) {
			fixed3 fogColor = unity_FogColor.rgb;
			#ifdef UNITY_PASS_FORWARDADD
			fogColor = 0;
			#endif
			color.rgb = lerp (fogColor, color.rgb, IN.fog);
		}
	  
	ENDCG
	}
	Fallback "Diffuse"
}

