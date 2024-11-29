# ABRAM
_Astronomical Bodies RAdiometric Model_

![temp](https://github.com/user-attachments/assets/343e67d4-4ba7-4fd7-a50d-aaf996a066f0)

**Installation** 
Clone the repository and the linked submodules by running the following git commands:

`git clone https://github.com/andrepiz/abram`

`git submodule init`

`git submodule update`

Then, simply run the script _call()_ to generate your first rendering.

**Usage** 
A single configuration file in YAML format is enough to generate a rendering. Provide the filepath of the yml file to the _abram.render_ constructor method in MATLAB:

`rend = abram.render('YOUR_FILE.YML)`

And a first image will be rendered. 
To generate new renderings, you can first modify the renderAgent properties with the desired parameters (for instance, new pose or new camera properties), then call: 

`renderAgent = rend.rendering()`

In this way most of the pre-processing activities will be skipped to lower computational time.

**Description**
ABRAM is a rendering tool to generate images of celestial quasi-spherical objects with radiometric consistency. The tool integrates radiometry equations on discretized surface sectors of a sphere according to the desired Bidirectional Reflectance Distribution Function (BRDF), resulting in a 3D point cloud of points that is then direct-gridded to the image frame. Several BRDFs are implemented and the user can mix them to find the more realistic model depending on the body considered. 

![image](https://github.com/user-attachments/assets/5affe851-186d-4cd4-b9d6-60eaf67562ba)

The user can provide also texture maps to increase the fidelity of the model at close range. Examples of renderings using only albedo (left), albedo + displacement (middle) and albedo + displacement + normal (right) are shown in the following: 

![temp](https://github.com/user-attachments/assets/20ef4518-5e67-48cf-a2be-605e1f6d0abc)

ABRAM has been validated against real space images acquired by the AMIE camera on-board of the SMART-1 mission.

![compar](https://github.com/user-attachments/assets/f2c9e409-5b99-4dc6-af20-30b4b5f90616)

With the addition of occlusions in v1.3, it is now possible to render close-range landing scenarios with good fidelity:

https://github.com/user-attachments/assets/b41429ba-aa4a-4a96-af28-8efbf9769a4e

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
