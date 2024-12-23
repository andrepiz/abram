# ABRAM
_Astronomical Bodies RAdiometric Model_

<p align="center">
  <img src="https://github.com/user-attachments/assets/18b6ea30-a4f8-444b-aa6f-cd889edf1805" height="445" />
  <img src="https://github.com/user-attachments/assets/22ebb7a9-32e4-49f9-992c-5c37f973b47a" height="445" /> 
</p>

**Installation** 
Clone the repository and the linked submodules by running the following git commands:

`git clone https://github.com/andrepiz/abram`

`git submodule init`

`git submodule update`

Then, simply run the script _call()_ to generate your first rendering.

**Usage** 
A single configuration file in YAML format is enough to generate a rendering. Provide the filepath of the yml file to the _abram.render_ constructor method in MATLAB:

`rend = abram.render('YOUR_FILE.YML')`

And a first image will be rendered. 
To generate new renderings, you can first modify the render properties with the desired parameters (for instance, new pose or new camera properties), then call: 

`rend = rend.rendering()`

In this way most of the pre-processing activities will be skipped to lower computational time. Examples of a multi-rendering call are provided in the script _call_multi()_.

**Description**
ABRAM is a rendering tool to generate images of celestial quasi-spherical objects with radiometric consistency. The tool integrates radiometry equations on discretized surface sectors of a sphere according to the desired Bidirectional Reflectance Distribution Function (BRDF), resulting in a 3D point cloud of points that is then direct-gridded to the image frame. Several BRDFs are implemented and the user can mix them to find the more realistic model depending on the body considered. 

![image](https://github.com/user-attachments/assets/5affe851-186d-4cd4-b9d6-60eaf67562ba)

The user can provide also texture maps to increase the fidelity of the model at close range. Examples of renderings using only albedo (left), albedo + displacement (middle) and albedo + displacement + normal (right) are shown in the following: 

![temp](https://github.com/user-attachments/assets/20ef4518-5e67-48cf-a2be-605e1f6d0abc)

ABRAM has been validated against real space images acquired by the AMIE camera on-board of the SMART-1 mission. Examples of real images (left) versus their rendering (right) at the same exposure time are depicted in the following pictures: 

<p align="center">
  <img src="https://github.com/user-attachments/assets/6acff1fa-8d92-4d34-944a-048c08c8322c" height="600" />
</p>

Note that detector noises and optical diffraction effects are not considered for the renderings. This explains the brightness differences that can be noticed in the background and the sharpness differences in the morphology. A slight geometrical shift is also present due to inaccuracies in the SPICE kernels used to retrieve the SMART-1 state.

**Publications** For more details on the implementation and capabilities, check the publications:

> A. Pizzetti, P. Panicucci, F.Topputo. "A Radiometric Consistent Render Procedure for Planets and Moons". 4th Space Imaging Workshop.

**Credits**
If you use the tool, please cite it in your work as: 
> A. Pizzetti. Astronomical Bodies RAdiometric Model (ABRAM)

| Version | Changelog |
| ------ | ------ |
|    v1.3    |Added occlusions; improved direct gridding efficiency; added smart-calling of methods       |
|    v1.2    |New object-oriented architecture; new fast mode with constant BRDF and no loops; increased fps at close range by pre-computing fov intersection; capability to merge QE and T spectra defined at different wavelengths        |
|    v1.1    |Added parallelization        |
|    v1.0    |Ready for dissemination        |

![cover](https://github.com/andrepiz/abram/assets/75851004/8163552c-7de7-4488-b037-895141902ab2)
