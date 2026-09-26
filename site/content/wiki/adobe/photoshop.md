---
weight: 1
title: "Adobe Photoshop"
---

[Adobe Photoshop](https://www.adobe.com/products/photoshop.html) is the preeminent Image Editing program produced by Adobe. Photoshop can be used for editing / enhancing photographs as well as producing entirely new image assets.

## File Management

Photoshop files are saved in `.psd` format. They can be stored on your local machine or in cloud storage at Adobe. These files often grow to extreamely large file sizes, making their binary format particularly unsuited for version control.

### Smart Objects

[Smart Objects](https://helpx.adobe.com/photoshop/using/create-smart-objects.html) are references to other image assets included in `.psd` files. These Smart Objects can either be `embeded` in the host file or `linked` from the file system. Smart Objects are represented as a type of layer in the host file. These layers can be cropped or transformed with simple position or scale transformations.

Embeded Smart Objects are copied 'as-is' into the host file. This means the host file can be moved without disrupting any linkages, but increases the file size.

Linked Smart Objects are more like symbolic links within the `.psd` file. Linked Smart Objects are absolute or relative file paths to include another image as a layer. Linked Smart Objects do not increase the host file size beyond simple metadata. In addition, multiple `.psd` files can all have linkages to the same source file. Updates to the linked file will update all instances included in host files. However, because the reference is a simple file path if either the PSD file or source file are moved the linkage will break.

### Artboards

[Artboards](https://helpx.adobe.com/photoshop/using/artboards.htm) are a group mechanism in PSD files for grouping one or more layers or layer groups. Artboards are sized to particular device resolution layouts and clip all their content to the view port. Use them for producing assets for different device formats.

### Libraries

[Libraries](https://helpx.adobe.com/creative-cloud/help/libraries.html) are packages of assets across all Adobe Apps which can be shared and synchronized across Creative Cloud. Useful for teams to maintain consistency of design elements across projects.

## Automation

### Actions

[Photoshop Actions](https://helpx.adobe.com/photoshop/using/actions-actions-panel.html) are a series of pre-defined tasks which can be played back on a single or group of files. These can be used to automate a large number of common, repeated operations of image editing. Actions can also be exported into `.atn` files which can be shared.

### Droplets

Photoshop [Droplets](https://helpx.adobe.com/photoshop/using/processing-batch-files.html) are "stand alone" application that apply one or more Actions to an image. Droplets can be created from a list of actions, and are linked to an install of Photoshop. Droplets actually involve a running instance of Photoshop.

## Data-Driven Graphics

[Data Driven Graphics](https://helpx.adobe.com/photoshop/using/creating-data-driven-graphics.html) are image templates with a set of variables which modify the image.

Variables come in three forms:
- Visibility variables show or hide the content of a layer.
- Pixel Replacement variables replace the pixels in the layer with pixels from another image file.
- Text Replacement variables replace a string of text in a type layer.
