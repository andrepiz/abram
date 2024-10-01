# ABRAM
_Astronomical Bodies RAdiometric Model_

**Installation** 
Clone the repository and the linked submodules by running the following git commands:

`git clone https://github.com/andrepiz/abram`

`git submodule init`

`git submodule update`


Then, simply run the script _call()_ to generate your first rendering.

**Description**
ABRAM is a rendering tool to generate images of celestial spherical objects with radiometric consistency. The tool integrates radiometry equations on discretized surface sectors of a sphere according to the desired Bidirectional Reflectance Distribution Function (BRDF), resulting in a 3D point cloud of points that is then gridded to the image frame. Examples of renderings are provided in the following pictures.

![image](https://github.com/user-attachments/assets/dfa669c9-837a-4d6d-9776-da4be33f9ec8)

Several BRDFs are implemented and the user can mix them to find the more realistic model depending on the body considered. 

![image](https://github.com/user-attachments/assets/5affe851-186d-4cd4-b9d6-60eaf67562ba)

ABRAM has been validated against real space images acquired by the AMIE camera on-board of the SMART-1 mission.

![compar](https://github.com/user-attachments/assets/f2c9e409-5b99-4dc6-af20-30b4b5f90616)

For more details on the implementation and capabilities, check the publications section.

**Publications**
_A. Pizzetti, P. Panicucci, F.Topputo. "A Radiometric Consistent Render Procedure for Planets and Moons". 4th Space Imaging Workshop._

**Credits**
If you use the tool, please cite it in your work as: 
_A. Pizzetti. Astronomical Bodies RAdiometric Model (ABRAM)_

![cover](https://github.com/andrepiz/abram/assets/75851004/8163552c-7de7-4488-b037-895141902ab2)
