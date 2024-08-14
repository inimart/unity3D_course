# Unity3D Course Materials

Hey there! 👋 Welcome to my Unity3D course repository. This is where I've stashed some of the materials I use in my Unity3D lectures.

## What's this all about?

This repo isn't meant to be a comprehensive guide to everything Unity3D (that'd be a *lot* of stuff!).
Instead, it's more of a highlight reel of my teaching work over the past few years. Think of it as a sneak peek into my classroom!
If you want to dive deeper into any of the topics I cover here, or you are interested in a Unity3D collaboration for teaching/consulting, feel free to reach out. 

## What's inside?

The slides here are from my 2021 course. They're the result of countless hours of research and hard work.
While they're free to use, I'd really appreciate a shout-out in your credits if you use them directly or draw inspiration from them.
It's always nice to get a little recognition, right? 😉

## A quick note on images

Most of the slides contain images that I've either:
- Created by myself
- Grabbed as screenshots from the Unity editor
- Borrowed from the official Unity guide
- Sourced from Wikipedia or other open-source places

If you spot any images that you think might be from your site or book and I haven't given proper credit, please let me know. I'll fix it up right away!

## What topics are covered?

Here's a taste of what you'll find in these slides (but there's plenty more!):
Feel free to dive in and explore. If you have any questions or spot anything that needs fixing, don't hesitate to reach out. Happy learning! 🚀

Here's the revised list of topics formatted in Markdown with bullet points instead of numbered lists:

### Shaders

- **Shader basics**: Introduction to shader types and the rendering pipeline in Unity.
- **Flynn Taxonomy**: Explanation of different parallel processing architectures, focusing on GPU's SIMD paradigm.
- **Rasterizer**: Description of how the rasterizer determines which pixels to pass to the pixel shader.
- **Shader components**: Overview of different file types associated with shaders and their syntax support in various IDEs.
- **BIRP/URP switch**: Instructions for quickly switching between Built-in Render Pipeline and Universal Render Pipeline.
- **Shader structure**: Explanation of main shader components like properties, subshaders, and passes.
- **Coordinate systems**: Explanation of Cartesian and Homogeneous coordinate systems in computer graphics.
- **Transformation matrices**: Introduction to scale, rotation, and translation matrices used in 3D transformations.
- **Coordinate spaces**: Description of different coordinate spaces like object space, world space, and view space.
- **Smoothstep function**: Explanation of the smoothstep function used for interpolation in shaders.
- **Rendering order**: Overview of how Unity determines the rendering order of objects.
- **Sorting techniques**: Explanation of different sorting methods for rendering transparent objects.
- **Z-Test and ColorMask**: How to use Z-testing and color masking in shaders.
- **Blending**: Introduction to blending modes and their implementation in shaders.
- **Textures**: How to use textures in shaders, including UV mapping and texture sampling.
- **Normal mapping**: Technique for adding surface detail without increasing polygon count.
- **Lighting models**: Introduction to basic lighting models including diffuse and specular reflection.
- **Metallic/Specular workflow**: Comparison of metallic and specular PBR workflows.
- **Stencil buffer**: Using the stencil buffer for advanced rendering effects.
- **GrabPass**: Technique for capturing and manipulating screen contents in shaders.
- **Screen shaders**: Creating post-processing effects using screen-space shaders.
- **Particle system shaders**: How to create custom shaders for particle systems.
- **Triplanar texturing**: Technique for applying textures without UV mapping.
- **Geometry shaders**: Introduction to geometry shaders and their applications.
- **Forward rendering**: Explanation of forward rendering and handling multiple lights.
- **ShaderGraph**: Introduction to Unity's visual shader creation tool, ShaderGraph.

### Optimization

- **Optimization tools**: Overview of various tools for general performance analysis, draw calls, shaders, geometry, code, and memory optimization.
- **Asset Database**: Explanation of Unity's Asset Database, how it converts and stores asset data for runtime use.
- **Asset import pipeline**: Description of Unity's asset import process, including name validation and the new Asset Import Pipeline 2.0.
- **Scripted importers**: How to create custom importers for new file types or override existing ones.
- **Asset postprocessors**: Using the AssetPostprocessor class to enforce standards and automate import settings.
- **Quality switcher**: Implementing a system to switch between different quality settings at runtime.
- **Texture compression**: Detailed explanation of texture compression techniques and formats for different platforms.
- **Model optimization**: Tips for optimizing 3D models, including rig settings and mesh compression.
- **CPU-bound optimizations**: Techniques to reduce CPU load, including culling, batching, and combining meshes.
- **GPU-bound optimizations**: Methods to optimize GPU performance, focusing on fillrate and memory bandwidth.
- **GPU skinning**: Explanation of GPU-based mesh skinning and its benefits.
- **Geometry optimization**: Techniques for simplifying meshes and adding detail through textures.
- **LOD (Level of Detail)**: Implementing LOD systems for models and animations to reduce rendering complexity at a distance.
- **Occlusion culling**: Detailed explanation of Unity's occlusion culling system and best practices for implementation.
- **Culling groups**: Using culling groups to optimize visibility checks and distance-based behavior.
- **Profiler usage**: Guide to using Unity's Profiler for performance analysis and optimization.
- **Scripting optimizations**: Various techniques for optimizing C# code in Unity, including data structure choices and memory management.
- **UI optimization**: Best practices for optimizing Unity's UI system, including canvas usage and batching.
- **Physics optimization**: Tips for optimizing physics simulations and raycasts.
- **Particle system optimization**: Techniques for improving the performance of particle systems.
- **Shader optimization**: Methods for optimizing shader performance and reducing variants.
- **Memory profiling**: Using Unity's Memory Profiler to analyze and optimize memory usage.
- **Build optimization**: Techniques for optimizing the final build, including code stripping and asset management.

### Particles

- **Particle System components**: Overview of emitters, parameters, and particle properties like emission rate, duration, velocity, and color over time.
- **Particle System Artist**: Description of the role and skills required for a particle system artist in game development.
- **Particle Effect panel**: Explanation of how to create and manipulate particle systems in Unity's Scene view.
- **Main module**: Detailed explanation of the main particle system settings, including start values, duration, simulation space, and scaling modes.
- **Emission module**: Description of time and distance-based emission, rate over time/distance, and burst emission.
- **Shape module**: Overview of 2D/3D shapes and meshes for particle emission, including spread and sequencing options.
- **Velocity and Force Over Time**: Explanation of how to control particle movement using velocity and force settings.
- **External Forces**: Description of how wind zones affect particle systems and their settings.
- **Collisions**: Detailed explanation of particle collision settings, including world and plane collisions.
- **Sub Emitters**: Overview of how to create complex effects using child particle systems triggered by parent particles.
- **Trail Renderer**: Explanation of the Trail Renderer component and its use in creating trailing effects behind objects.
- **Force Field**: Introduction to Force Fields and their effect on particle movement.
- **Vector Field**: Brief mention of 3D textures for creating complex particle movement patterns.
- **Noise**: Detailed explanation of Curl Noise and its application in particle systems for creating natural-looking movement.
- **Renderer module**: Overview of rendering options for particles, including billboard modes, mesh rendering, and sorting.
- **Lights module**: Description of how to add dynamic lights to particles and their performance considerations.
- **Custom Data**: Explanation of how to add custom data to particles for use in scripts or shaders.
- **Masking**: Tutorial on creating a portal effect using various particle system techniques and masking.
- **Performance considerations**: Tips for optimizing particle systems, including using appropriate data structures and efficient update methods.
- **Texture atlasing**: Explanation of how to use texture atlases to reduce draw calls in particle systems.
- **GPU Instancing**: Description of how to use GPU instancing to improve particle system performance.
- **Visual Effect Graph**: Brief introduction to Unity's Visual Effect Graph as a more advanced particle system tool.

### Lighting

- **Shadow mapping**: Explanation of the shadow mapping technique, including depth map creation and light space transformation.
- **Shadow acne**: Description of the shadow acne problem and solutions like shadow bias and back face rendering.
- **Shadow bias**: Detailed explanation of depth bias and normal bias settings to reduce shadow acne issues.
- **Peter panning**: Description of the peter panning effect and solutions like avoiding thin geometry.
- **PCF (Percentage Close Filtering)**: Explanation of PCF technique for smoother shadow borders.
- **CSM (Cascade Shadow Maps)**: Overview of cascade shadow mapping for improving shadow quality at different distances.
- **Lightmap UVs**: Explanation of lightmap UV creation and importance in baked lighting.
- **UV channels**: Description of different UV channels used in Unity for various purposes like texturing and lightmapping.
- **Baked lightmap UVs**: Detailed explanation of creating and optimizing UVs for baked lightmaps.
- **Cornell Box**: Introduction to the Cornell Box concept and its use in global illumination testing.
- **Light types**: Overview of different light types in Unity, including directional, point, area, and emissive lights.
- **Cookies**: Explanation of light cookies and their use in shaping light patterns.
- **Halo and lens flare**: Description of halo and lens flare effects for enhancing light sources.
- **Lightmapper components**: Overview of the precompute, real-time solver, and light map baker components.
- **Baked GI (Global Illumination)**: Detailed explanation of baked global illumination settings and techniques.
- **Light probes**: Description of light probes and their use in lighting dynamic objects.
- **Realtime GI**: Explanation of real-time global illumination and its differences from baked GI.
- **Precompute/Packing/Clustering**: Detailed description of the precompute and packing processes for lightmaps.
- **Real-time solver**: Description of the real-time GI solver and its stages.
- **Emissive RT GI**: Explanation of using emissive materials with real-time global illumination.
- **Reflection probes**: Detailed overview of reflection probes, their types, and usage.
- **Mixed lighting**: Explanation of mixed lighting modes, including baked indirect, shadowmask, and subtractive.
- **Forward vs Deferred rendering**: Comparison of forward and deferred rendering paths and their impact on lighting.
- **Post-processing**: Overview of various post-processing effects related to lighting, such as bloom and color grading.
- **HDR and color spaces**: Explanation of High Dynamic Range (HDR) rendering and color space considerations.
- **Environment lighting**: Description of environment lighting techniques, including skyboxes and image-based lighting.

### Git

- **Version Control Systems**: Introduction to the concept and importance of version control in software development.
- **Git basics**: Overview of Git as a distributed version control system and its key features.
- **Creating a repository**: Steps to initialize a new Git repository or clone an existing one.
- **Basic Git workflow**: Explanation of the working directory, staging area, and repository structure.
- **Git status**: How to check the status of files in the working directory and staging area.
- **Git add**: Instructions for adding files to the staging area for commit.
- **Git commit**: How to create a commit with a descriptive message to save changes.
- **Git log**: Viewing the commit history and understanding commit hashes.
- **Git diff**: Comparing changes between different commits or branches.
- **Branching**: Creating and managing branches for parallel development.
- **Merging**: How to combine changes from different branches.
- **Resolving conflicts**: Techniques for handling merge conflicts when they occur.
- **Remote repositories**: Working with remote repositories on platforms like GitHub or GitLab.
- **Git push**: Uploading local commits to a remote repository.
- **Git pull**: Fetching and merging changes from a remote repository.
- **Git fetch**: Retrieving changes from a remote without automatically merging.
- **Forking**: Creating a personal copy of a repository for independent development.
- **Pull requests**: Submitting changes to the original repository for review and integration.
- **Git ignore**: Configuring Git to ignore specific files or directories.
- **Git stash**: Temporarily saving uncommitted changes to switch branches.
- **Git rebase**: Reapplying commits on top of another base tip for a cleaner history.
- **Git cherry-pick**: Applying specific commits from one branch to another.
- **Git reset**: Undoing changes or moving the HEAD to a specific commit.
- **Git revert**: Creating a new commit that undoes changes from a previous commit.
- **Git tags**: Creating and managing tags for marking specific points in history.
- **Git hooks**: Automating actions at certain points in the Git workflow.
- **Git LFS (Large File Storage)**: Managing large files in Git repositories.
- **Git flow**: Overview of a popular branching model for Git workflows.
- **Git best practices**: Tips for writing good commit messages and maintaining a clean history.
- **Git GUI clients**: Introduction to graphical user interfaces for Git, such as SourceTree or GitKraken.
- **Git and Unity**: Specific considerations for using Git with Unity projects, including .gitignore setup.
- **Git submodules**: Managing external dependencies as subprojects within a Git repository.
