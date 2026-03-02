# ABRAM
_**A** physically-**B**ased **R**endering **A**pplication in **M**atlab_ for planets, moons, and small bodies.

### Installation & Usage
Clone the repository and the linked submodules by running the following git commands:

`git clone https://github.com/andrepiz/abram`

`git submodule init`

`git submodule update`

Then, simply run the script 
`call()` to generate your first rendering.

Check the [ABRAM wiki](https://github.com/andrepiz/abram/wiki) to access the full documentation.

### Dependencies 
ABRAM has been developed and tested in MATLAB r2023b with the following dependencies:
- Image Processing Toolbox (required)
- Parallel Computing Toolbox (required for multi-threading)
- Statistics and Machine Learning Toolbox (required for image noises)

<p align="center">
  <img src="https://github.com/user-attachments/assets/1dbbfb22-8131-48f5-b696-126932abd70b" width="800" />
</p>

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

<p align="center">
  <img src="https://github.com/user-attachments/assets/b46155fe-9300-4ca2-bd49-9c792e8a4546" width="457" />
  <img src="https://github.com/user-attachments/assets/8b6ca482-f38b-41ca-b07d-0f9907651cc0" width="343" />
  <img src="https://github.com/user-attachments/assets/67997677-9934-4707-8bdb-86c1c35ebce3" height="400" />
  <img src="https://github.com/user-attachments/assets/c26ddb2e-e44f-4b11-9723-3365647d604f" height="400" />
</p>

### Credits 
If you use the tool, please cite it in your work with: 
> A. Pizzetti, P. Panicucci, F. Capolupo, F.Topputo. "Development and Validation of a Physically Based Rendering Methodology for Celestial Bodies". Acta Astronautica (2026).

### Publications 
ABRAM has been used in the following publications:
> A. Pizzetti, P. Panicucci, F.Topputo. "A Bottom-Up Approach for Radiometric Validation of Synthetic Imagery". Inter-Agency GNC V&V Workshop (IAGNC 2025).
> 
> A. Pizzetti, P. Panicucci, F.Topputo. "A Radiometric Consistent Render Procedure for Planets and Moons". 4th Space Imaging Workshop.
> 
> P. Panicucci, C. Balossi, F. Ornati, F. Piccolo, A. Pizzetti, F.Topputo, F. Capolupo. "What if Star Trackers Were Navigation Cameras?". 35th AAS/AIAA Space Flight Mechanics Meeting.

### Get involved 
Feel free to open an [issue](https://github.com/andrepiz/abram/issues) to report a bug or ask for a feature. 
If you want to contribute to the project, or you need some help in the usage of the tool, e-mail me at andrea.pizzetti@polimi.it 

### Changelog 
| Version | Changelog |
| ------ | ------ |
|    v1.7    |Changed algorithm of frustum culling; added raymarching shadow culling algorithm; added depthbuffer shadow culling algorithm; added depth map as optional output; added new concentrated sampling; refactored code and architecture; added default objects initialization; extended flexibility of inputs |
|    v1.6    |Added horizon maps; added support to tiled maps; added support to multi-threads parallelization |
|    v1.5    |Added support to hyperspectral maps; added support to non-spherical shapes; added tutorials |
|    v1.4    |Improved frame rate; added Hapke reflection model; added ellipsoidal shapes |
|    v1.3    |Added occlusions; improved direct gridding efficiency; added smart-calling of methods       |
|    v1.2    |New object-oriented architecture; new fast mode with constant BRDF and no loops; increased fps at close range by pre-computing fov intersection; capability to merge QE and T spectra defined at different wavelengths        |
|    v1.1    |Added parallelization        |
|    v1.0    |Ready for dissemination        |
