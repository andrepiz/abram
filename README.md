# ABRAM
_**A**stronomical **B**odies **R**endering **A**pplication for **M**ission design_

![optimal_texp](https://github.com/user-attachments/assets/b46155fe-9300-4ca2-bd49-9c792e8a4546)

**INSTALLATION:** 
clone the repository and the linked submodules by running the following git commands:

`git clone https://github.com/andrepiz/abram`

`git submodule init`

`git submodule update`

Then, simply run the script _call()_ to generate your first rendering.

<p align="center">
  <img src="https://github.com/user-attachments/assets/9211622b-cfd4-4cae-a7a2-45427ed514c9" height="200" />
  <img src="https://github.com/user-attachments/assets/2331dccb-6b9b-4926-b54e-6c5d374c27fd" height="200" />
  <img src="https://github.com/user-attachments/assets/ab6fb2e6-84e3-4a5c-840e-25acaf31de39" height="200" />
  <img src="https://github.com/user-attachments/assets/2a4ac9df-9f75-4a3e-8aef-da8115591182" height="200" />
  <img src="https://github.com/user-attachments/assets/f3c50857-0731-4be8-b6cb-da49013f4e77" height="200" />
  <img src="https://github.com/user-attachments/assets/8e018275-5a4e-4f78-9a4c-ed0757ec9e67" height="200" />
  <img src="https://github.com/user-attachments/assets/3b9f1943-3c72-48f7-ae86-5f648fab29eb" height="200" />
  <img src="https://github.com/user-attachments/assets/5eba8dd5-4351-4833-9181-57678352ba61" height="200" />
</p>

**USAGE:** 
a single configuration file in YAML format is enough to generate a rendering. Provide the filepath of the yml file to the _abram.render_ constructor method in MATLAB:

`rend = abram.render('YOUR_FILE.YML')`

And a first image will be rendered. 
To generate new renderings, you can first modify the render properties with the desired parameters (for instance, new pose or new camera properties), then call: 

`rend = rend.rendering()`

In this way most of the pre-processing activities will be skipped to lower computational time. Examples of a multi-rendering call are provided in the script _call_multi()_.

The repository also includes some tutorials to help users become familiar with the toolbox:
- moon_trajectory: generate a dataset of Moon images along a trajectory defined in ECI or IAU Body-fixed frame
- hyperspectral_texture: how to embed an high-resolution hyperspectral albedo texture tile in the rendering workflow
  
![https://github.com/user-attachments/assets/20ef4518-5e67-48cf-a2be-605e1f6d0abc](https://github.com/user-attachments/assets/22ebb7a9-32e4-49f9-992c-5c37f973b47a)

**DEPENDENCIES:**
ABRAM has been developed and tested in MATLAB r2023b with the following dependencies:
- Image Processing Toolbox (required)
- Parallel Computing Toolbox (for multi-thread rendering)
- Statistics and Machine Learning Toolbox (for image noises)
  
**DESCRIPTION:**
ABRAM is a physically-based validated render engine to generate images of celestial quasi-spherical objects with radiometric consistency. The tool integrates radiometry equations on discretized surface sectors of a sphere according to the desired Bidirectional Reflectance Distribution Function (BRDF), resulting in a 3D point cloud of points that is then direct-gridded to the image frame. ABRAM can be used for camera design, radiometry-related analysis and generation of datasets for training or testing of vision-based navigation algorithms. 

Several BRDFs are implemented and the user can mix them to find the more realistic model depending on the body considered. 

![image](https://github.com/user-attachments/assets/5affe851-186d-4cd4-b9d6-60eaf67562ba)

The user can provide also texture maps to increase the fidelity of the model at close range. Examples of renderings using only albedo (left), albedo + displacement (middle) and albedo + displacement + normal (right) are shown in the following: 

![temp](https://github.com/user-attachments/assets/20ef4518-5e67-48cf-a2be-605e1f6d0abc)

Normal maps of different planets and moons of the solar system have been generated as byproduct of ABRAM development and are available at the following [link](https://zenodo.org/records/14936972).

ABRAM has been validated against real space images acquired by the AMIE camera on-board of the SMART-1 mission. Examples of real images (above) versus their rendering (bottom) at the same exposure time are depicted in the following pictures: 

![validation_amie_corr_tiled_horz](https://github.com/user-attachments/assets/5416e9f9-cfd0-48ac-bf6f-f3465ed26f1e)
![validation_amie_ideal_tiled_horz](https://github.com/user-attachments/assets/c73be108-327f-4f7f-94c0-2bc640a23349)

ABRAM also supports simple non-spherical shapes such as disks, cylinders, cubes, sticks, plates:

![debrisField](https://github.com/user-attachments/assets/8b6ca482-f38b-41ca-b07d-0f9907651cc0)

**DOCUMENTATION:** documentation is on its way. In the meantime, for more details on the implementation and capabilities, check the following publications:
> A. Pizzetti, P. Panicucci, F.Topputo. "A Radiometric Consistent Render Procedure for Planets and Moons". 4th Space Imaging Workshop.

**CREDITS:**
if you use the tool, please cite it in your work as: 
> A. Pizzetti, P. Panicucci, F.Topputo. "Development and Validation of an Astronomical Bodies Rendering Application for Mission design". Under review.

**CONTRIBUTING:**
feel free to open an issue to report a bug or ask for a functionality. Do you want to contribute to the project or you need some help in the usage? e-mail me at andrea.pizzetti@polimi.it 

| Version | Changelog |
| ------ | ------ |
|    v1.5    |Added support to hyperspectral maps; added support to non-spherical shapes; added tutorials |
|    v1.4    |Improved frame rate; added Hapke reflection model; added ellipsoidal shapes |
|    v1.3    |Added occlusions; improved direct gridding efficiency; added smart-calling of methods       |
|    v1.2    |New object-oriented architecture; new fast mode with constant BRDF and no loops; increased fps at close range by pre-computing fov intersection; capability to merge QE and T spectra defined at different wavelengths        |
|    v1.1    |Added parallelization        |
|    v1.0    |Ready for dissemination        |
