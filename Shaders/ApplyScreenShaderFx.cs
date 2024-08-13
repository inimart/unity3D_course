using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ApplyScreenShaderFx : MonoBehaviour
{
    public bool ApplyScreenFx;
    [Range(0,1)]
    public float Val;
    public string FloatShaderVarName;
    public Texture2D Img;
    public string Texture2DShaderVarName;
    public Material material;

/*
OnRenderImage is called after all rendering is complete to render image.
It allows you to modify final image by processing it with shader based filters.
The incoming image is source render texture. The result should end up in
destination render texture. You must always issue a Graphics.Blit or render
a fullscreen quad if you override this method.
When there are multiple image filters attached to the camera, they process
image sequentially, by passing first filter's destination as the source to
the next filter.
This message is sent to all scripts attached to the camera.
*/
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!ApplyScreenFx)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if (FloatShaderVarName != "")
            material.SetFloat(FloatShaderVarName, Val);
        if (Texture2DShaderVarName != null)
            material.SetTexture(Texture2DShaderVarName, Img);

        Graphics.Blit(source, destination, material);
    }
}