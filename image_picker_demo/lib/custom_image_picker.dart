import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';


class CustomImagePicker extends StatefulWidget {
  final String title;
  CustomImagePicker({Key key, this.title}):super(key:key);
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  Future <File> _imageFile;
  bool isVideo = false;
  VideoPlayerController _controller;//视频播放器
  VoidCallback listener;//闭包 or block

  void _onImageButtonPressed(ImageSource source) {
    setState(() {
      if (_controller != null) {
        _controller.setVolume(0.0);
        _controller.removeListener(listener);
      }

      if (isVideo) {
        ImagePicker.pickVideo(source: source).then((File file){
          if (file != null && mounted) {
            setState(() {
               _controller = VideoPlayerController.file(file)
                  ..addListener(listener)
                  ..setVolume(1.0)//音量
                  ..initialize()//初始化(异步)
                  ..setLooping(true)//循环播放
                  ..play();                          
            });
          }
        });
      } else {
        _imageFile = ImagePicker.pickImage(source: source);
      }
    });
  }

  @override
    void deactivate() {
      if (_controller != null) {
        _controller.setVolume(1.0);
        _controller.removeListener(listener);
      }
      super.deactivate();
    }

  @override
    void dispose() {
      if (_controller != null) {
        _controller.dispose();
      }
      super.dispose();
    }
    
  @override
    void initState() {
      super.initState();
      listener = (){
        setState(() {});
      };
    }  
  

  Widget _previewVideo(VideoPlayerController controller) {
    if (controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    } else if (controller.value.initialized) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatioVideo(controller),
      );
    } else {
      return const Text(
        'Error Loading Video',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _previewImage() {
     return FutureBuilder<File>(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.file(snapshot.data);
          } else if (snapshot.error != null) {
            return const Text(
              'Error picking image.',
              textAlign: TextAlign.center,
            );
          } else {
            return const Text(
              'You have not yet picked an image.',
              textAlign: TextAlign.center,
            );
          }
        }
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0.0,
      ),
      body: Center(
        child: isVideo ? _previewVideo(_controller) : _previewImage(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          //相册选取照片
          FloatingActionButton(
            onPressed: () {
              isVideo = false;
              _onImageButtonPressed(ImageSource.gallery);
            },
            child: const Icon(Icons.photo_library),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            //拍照
            child: FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera);
              },
              child: const Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            //'从相册选取视频'
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
              child: const Icon(Icons.video_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            //视频录制
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
              },
              child: const Icon(Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }
}


class AspectRatioVideo extends StatefulWidget {
  final VideoPlayerController controller;
  AspectRatioVideo(this.controller);
  _AspectRatioVideoState createState() => _AspectRatioVideoState();
}

class _AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;
  VoidCallback listener;

  @override
    void initState() {
      super.initState();
      listener = (){
        if (!mounted) {
          return;
        }
        if (initialized != controller.value.initialized) {
          initialized = controller.value.initialized;
          setState(() {});
        }
      };
      controller.addListener(listener);
    }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      final Size size = controller.value.size;
      return Center(
        child: AspectRatio(
          aspectRatio: size.width / size.height,
          child: VideoPlayer(controller),
        ),
      );
    } else {
      return Container();
    }
  }
  }