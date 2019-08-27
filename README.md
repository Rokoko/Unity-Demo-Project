<h2 align="center"> Rokoko Studio - Sample project for Unity</h1>

[Rokoko Studio](https://www.rokoko.com/en/products/studio) is A powerful and intuitive software for recording, visualizing and exporting motion capture.

This sample project for Unity contains a more advanced setup with HTC vive integration for virtual camera use and facial live streaming using the Rokoko Remote app. 

![Unity Viewport](Images/unityViewport.PNG?raw=true)

If you want to learn more about the basics of setting up a Smartsuit with Unity, you can watch this tutorial: https://www.rokoko.com/en/explore/blog/how-to-forward-real-time-data-to-your-character-in-unity 
Or you can browse the tutorials on https://www.rokoko.com/

---

## Setting up the streaming between Studio and Unity

In order to use face and tracker information, you'll first need to setup a connection between Rokoko Studio and Unity. This requires the Rokoko Live plugin for unity, which has already been imported in this project. 

In Rokoko Studio, set up live streaming as normal. For the sample project we are using the port 14043 for suits and 14045 for virtual production. 

In the sample project in Unity, we have an empty game object with two components on it: a smartsuit receiver component, and a Virtual Production Receiver component. 
Set the correct ports on both components if they are not already set. 

Rokoko is now streaming any live suits/trackers/faces, and Unity is now looking for the stream whenever play mode in the editor is activated. 

## Virtual Camera Setup

In Studio, connect to steamVR and add trackers. Assign one of these trackers to any prop. Now the tracker data is being streamed to Unity

Inside Unity, while in play mode, you can now see your tracker inputs in the "Trackers" section, under the Virtual Production Receiver component.

You can then create a gameObject (we use one called Tracker01 here), and set the ID you want in its "Virtual Production Tracker" component. Now this empty gameObject will follow the tracker transform, and you can then parent a camera under this empty, to create a simple Virtual Camera. 

## Face setup

In Studio, connect to a smartphone with Rokoko Remote.

On the smartphone, enable facial capture.

Back in studio, drag the face input to a body profile, now the face data is being streamed to Unity

Inside Unity, under the Virtual Production Receiver component, you can now see a face stream under "Faces", if you are in play mode. Copy the Face ID. 

There is then a "Face" component on the "mimeCharacter" GameObject (Or your custom character). Paste the Face ID on this component. This is where the inputs from the stream are retargeted to drive blendShapes on a chose "Skinned Mesh Renderer". If you have custom character, you can type in the names of the existing blendShapes on that mesh, and they will be driven by the stream. 

