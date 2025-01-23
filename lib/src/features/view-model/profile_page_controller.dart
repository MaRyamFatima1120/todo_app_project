import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePageController extends GetxController {
  // Store image URLs for two separate images
  var firstImageUrl = Rx<String?>(null);
  var secondImageUrl = Rx<String?>(null);
  final ImagePicker imagePicker = ImagePicker();

  RxString userName ="".obs;
  RxString userEmail ="".obs;
  RxString userPassword ="".obs;

  //method of name
  void loadUser() async{
    SharedPreferences prefs =await SharedPreferences.getInstance();
    userName.value =prefs.getString('user')?? 'Guest';
    userEmail.value =prefs.getString('email')?? 'Not Provided';
    userPassword.value =prefs.getString('password')?? 'No Password';
  }



  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadImagePath();
    loadUser();
  }
  //Method to load image paths to SharedPreferences

  Future<void> loadImagePath() async{
    SharedPreferences prefs= await SharedPreferences.getInstance();
    firstImageUrl.value =prefs.getString('firstImageUrl');
    secondImageUrl.value =prefs.getString('secondImageUrl');
    print('Loaded First Image URL: ${firstImageUrl.value}');
  }

  // Save user name to SharedPreferences
  Future<void> updateUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = name;
    await prefs.setString('user', name);
  }

  // Save user password to SharedPreferences
  Future<void> updateUserPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    userPassword.value = password;
    await prefs.setString('password', password);
  }

  // Method to save image paths to SharedPreferences
  Future<void> saveImagePath(String key,String path) async{
   SharedPreferences prefs= await SharedPreferences.getInstance();
   await prefs.setString(key, path);
  }

  // Pick the first image from the gallery
  Future<void> uploadFirstImage() async {
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print('First Image Path: ${pickedFile.path}');
      firstImageUrl.value = pickedFile.path;
      await saveImagePath('firstImageUrl', pickedFile.path);
    }
  }

  // Pick the second image from the gallery
  Future<void> uploadSecondImage() async {
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      secondImageUrl.value = pickedFile.path;
      await saveImagePath('secondImageUrl', pickedFile.path);
    }
  }

}
