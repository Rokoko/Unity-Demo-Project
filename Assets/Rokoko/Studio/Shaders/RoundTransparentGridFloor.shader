// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Floor/RoundGridFloor"
{
	Properties
	{
		[NoScaleOffset]_MainTexture("MainTexture", 2D) = "white" {}
		_Tiles("Tiles", Range( 0.2 , 4)) = 0.04
		_SubTiles("SubTiles", Int) = 4
		_Radius("Radius", Float) = 2
		_FadeDistance("FadeDistance", Float) = 2
		_MainColor("MainColor", Color) = (0.5849056,0.5849056,0.5849056,0)
		_GridColor("GridColor", Color) = (1,1,1,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float4 _MainColor;
		uniform float4 _GridColor;
		uniform sampler2D _MainTexture;
		uniform float _Tiles;
		uniform int _SubTiles;
		uniform float _FadeDistance;
		uniform float _Radius;
		uniform sampler2D _GrabTexture;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float4 _black = float4(0,0,0,0);
			float3 ase_worldPos = i.worldPos;
			float4 transform127 = mul(unity_WorldToObject,float4( ase_worldPos , 0.0 ));
			float4 appendResult129 = (float4(transform127.x , transform127.z , 0.0 , 0.0));
			float4 lerpResult114 = lerp( _MainColor , _GridColor , max( tex2D( _MainTexture, ( appendResult129 * _Tiles ).xy ).r , tex2D( _MainTexture, ( appendResult129 * _SubTiles * _Tiles ).xy ).r ));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float simplePerlin2D148 = snoise( ( ase_screenPosNorm * 2048.0 ).xy );
			float ScreenRandom152 = ( ( simplePerlin2D148 - 1.0 ) * 0.0008 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float clampResult126 = clamp( ( (0.0 + (length( ( ase_vertex3Pos * ase_objectScale ) ) - ( _FadeDistance + _Radius )) * (1.0 - 0.0) / (_Radius - ( _FadeDistance + _Radius ))) + ( ScreenRandom152 * 32.0 ) ) , 0.0 , 1.0 );
			float Mask84 = clampResult126;
			float4 lerpResult86 = lerp( _black , ( lerpResult114 + ScreenRandom152 ) , Mask84);
			o.Albedo = lerpResult86.rgb;
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor106 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ase_grabScreenPos ) );
			float4 lerpResult107 = lerp( screenColor106 , _black , Mask84);
			o.Emission = lerpResult107.rgb;
			o.Occlusion = Mask84;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
721;610;1811;1053;317.91;748.674;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;146;-135.0199,-941.0858;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;2048;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;145;-159.6499,-1118.281;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;108.3001,-1051.426;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;148;271.6201,-1083.426;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;130;-1492.192,-287.5355;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;149;395.9418,-901.1499;Half;False;Constant;_Float2;Float 2;10;0;Create;True;0;0;False;0;0.0008;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;150;542.7732,-1078.884;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;127;-1253.192,-373.5355;Float;False;1;0;FLOAT4;20,20,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectScaleNode;134;-896.1921,120.4645;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;137;-903.1921,-33.53546;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;140;-829.1921,-166.5355;Float;False;Property;_SubTiles;SubTiles;2;0;Create;True;0;0;False;0;4;1;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;657.3772,-897.5698;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-352.7222,684.8953;Float;False;Property;_Radius;Radius;4;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-598.9555,607.2492;Float;False;Property;_FadeDistance;FadeDistance;5;0;Create;True;0;0;False;0;2;9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-745.1921,-451.5355;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-950.1921,-250.5355;Float;False;Property;_Tiles;Tiles;1;0;Create;True;0;0;False;0;0.04;3;0.2;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-589.1921,29.46454;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;156;9.089966,757.326;Float;False;152;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-150.5376,510.1237;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;133;-327.1921,132.4645;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-565.1921,-453.5355;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-499.145,-215.2919;Float;False;3;3;0;FLOAT4;0,0,0,0;False;1;INT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-718.2371,-681.6383;Float;True;Property;_MainTexture;MainTexture;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;3210909188b287d479844ea1fe70796e;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;859.3772,-893.5698;Float;False;ScreenRandom;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;124;109.9944,476.2878;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;111;-373.8739,-528.3384;Float;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;273.09,751.326;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;32;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;117;-311.5051,-303.412;Float;True;Property;_TextureSample2;Texture Sample 2;9;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;25;34.1372,-877.5474;Float;False;Property;_MainColor;MainColor;6;0;Create;True;0;0;False;0;0.5849056,0.5849056,0.5849056,0;0.5019608,0.5019608,0.5019608,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;39;66.1444,-645.2015;Float;False;Property;_GridColor;GridColor;7;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;120;108.3364,-449.3719;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;155;396.09,407.326;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;364.09,-444.6741;Float;False;152;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;114;384.0237,-568.5497;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;126;568.8995,505.585;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;153;643.09,-552.6741;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;106;777.6548,-189.9321;Float;False;Global;_GrabScreen0;Grab Screen 0;8;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;123;844.5237,103.9214;Float;False;84;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;770.397,529.1704;Float;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;388.1246,-269.1199;Float;False;84;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;102;411.6117,-38.82932;Float;False;Constant;_black;black;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;144;-1157.41,-536.1741;Float;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;142;-937.4104,-540.1741;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;94;-709.0233,413.0014;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectScaleNode;141;-1337.231,-552.4367;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;122;1189.246,104.9812;Float;False;84;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;-480.9125,396.5108;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;86;802.6104,-366.8469;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;143;-944.4104,-426.1741;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;107;1048.637,-65.39899;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;93;-324.0916,340.3794;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-1257.953,66.76419;Float;False;Constant;_ff;ff;3;0;Create;True;0;0;False;0;4;4;1;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-714.3265,275.1477;Float;False;Property;_Center;Center;3;1;[HideInInspector];Create;True;0;0;False;0;0.6,0.8;0.6,0.8;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;90;1431.994,-183.2848;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;Floor/RoundGridFloor;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;147;0;145;0
WireConnection;147;1;146;0
WireConnection;148;0;147;0
WireConnection;150;0;148;0
WireConnection;127;0;130;0
WireConnection;151;0;150;0
WireConnection;151;1;149;0
WireConnection;129;0;127;1
WireConnection;129;1;127;3
WireConnection;135;0;137;0
WireConnection;135;1;134;0
WireConnection;125;0;30;0
WireConnection;125;1;8;0
WireConnection;133;0;135;0
WireConnection;139;0;129;0
WireConnection;139;1;138;0
WireConnection;118;0;129;0
WireConnection;118;1;140;0
WireConnection;118;2;138;0
WireConnection;152;0;151;0
WireConnection;124;0;133;0
WireConnection;124;1;125;0
WireConnection;124;2;8;0
WireConnection;111;0;2;0
WireConnection;111;1;139;0
WireConnection;157;0;156;0
WireConnection;117;0;2;0
WireConnection;117;1;118;0
WireConnection;120;0;111;1
WireConnection;120;1;117;1
WireConnection;155;0;124;0
WireConnection;155;1;157;0
WireConnection;114;0;25;0
WireConnection;114;1;39;0
WireConnection;114;2;120;0
WireConnection;126;0;155;0
WireConnection;153;0;114;0
WireConnection;153;1;154;0
WireConnection;84;0;126;0
WireConnection;142;0;127;1
WireConnection;142;1;141;1
WireConnection;95;0;94;1
WireConnection;95;1;94;3
WireConnection;86;0;102;0
WireConnection;86;1;153;0
WireConnection;86;2;85;0
WireConnection;143;0;127;3
WireConnection;143;1;141;3
WireConnection;107;0;106;0
WireConnection;107;1;102;0
WireConnection;107;2;123;0
WireConnection;93;0;16;0
WireConnection;93;1;95;0
WireConnection;90;0;86;0
WireConnection;90;2;107;0
WireConnection;90;5;122;0
ASEEND*/
//CHKSM=6D3E09E778F5B1900F4E53EF1544E50046B0B9F4