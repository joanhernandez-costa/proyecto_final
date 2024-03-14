
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/UserService.dart';
import 'package:app_final/widgets/CustomButtons.dart';
import 'package:app_final/widgets/CustomTableBuilder.dart';
import 'package:app_final/widgets/CustomTableStyle.dart';
import 'package:flutter/material.dart';
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/services/MediaService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/screens/SettingsScreen.dart';
import 'package:app_final/services/ValidationService.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userNameController.text = UserService.currentUser.value?.userName ?? '';
    _mailController.text = UserService.currentUser.value?.mail ?? '';    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorService.background,
      body: SafeArea(
        child: SingleChildScrollView( // Usar SingleChildScrollView
          child: Column( // Cambiar ListView por Column
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  NavigationService.replaceScreen(context, SettingsScreen());
                },
                alignment: Alignment.topLeft,
              ),
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(UserService.currentUser.value!.profileImageUrl ?? 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/Recurso%2090.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL1JlY3Vyc28gOTAucG5nIiwiaWF0IjoxNzA5NzIxNjA3LCJleHAiOjE3NDEyNTc2MDd9.VC_GF_l8h2wkB5bZKxa9l8wpjL06rHJEXr3RpcpduVQ&t=2024-03-06T10%3A40%3A10.742Z'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: pickAndUploadImage,
                ),
              ),
              _buildEditableField('Nombre de Usuario', _userNameController),
              _buildEditableField('Correo Electrónico', _mailController),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: SecondaryButton().createButton(const Text('Actualizar'), () {_updateProfile();}),
              ),
              const SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomTableBuilder(
                  numberOfColumns: 1,
                  horizontalSpacing: 10,
                  verticalSpacing: 10,
                  cellSize: const Size(100, 100),
                  fixedSize: true,
                  style: CustomTableStyle(
                    backgroundColor: ColorService.background,
                    borderRadius: 30,
                    padding: const EdgeInsets.all(20),
                    border: Border.all(color: ColorService.changeLightness(ColorService.background, 0.8), width: 5),
                  ),
                  itemCount: 20,
                  cellBuilder: (context, index) {
                    return Center(
                      child: Text(
                        'Item $index'
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorService.textOnPrimary,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        //onEditingComplete: ,
      ),
    );
  }

  void pickAndUploadImage() async {
    var url = await MediaService.pickImage();
    setState(() {
      UserService.currentUser.value!.profileImageUrl = url;
    });
  }

  void _updateProfile() {
    String? userNameError = ValidationService.validateUserName(_userNameController.text);
    String? mailError = ValidationService.validateMailForSignUp(_mailController.text);

    if (userNameError != null || mailError != null) {      
      print('Error: $userNameError, $mailError');
      return;
    }

    AppUser updatedUser = AppUser(
      userName: _userNameController.text,
      mail: _mailController.text,
      password: UserService.currentUser.value!.password,
      id: UserService.currentUser.value!.id, 
      profileImageUrl: UserService.currentUser.value!.profileImageUrl
    );

    UserService.updateCurrentUser(updatedUser);
  }
}
