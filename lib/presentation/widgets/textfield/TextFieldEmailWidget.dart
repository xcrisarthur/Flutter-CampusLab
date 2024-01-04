import 'package:flutter/material.dart';
import 'package:flutter_uilogin/domain/usecases/AuthUsecase.dart';
import 'package:provider/provider.dart';


class TextfieldEmailWidget extends StatefulWidget {
  const TextfieldEmailWidget({super.key, required this.controller});
  final TextEditingController controller;

  @override
  State<TextfieldEmailWidget> createState() => _TextfieldEmailWidgetState();
}

class _TextfieldEmailWidgetState extends State<TextfieldEmailWidget> {
  @override
  Widget build(BuildContext context) {
    var loadAuth = Provider.of<AuthProvider>(context);
    return Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Text("EMAIL",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
    const SizedBox(height: 10,),
    Container(
      width: 250, // Atur lebar sesuai keinginan Anda
      child: TextFormField(
        controller: widget.controller,
        autovalidateMode:  AutovalidateMode.onUserInteraction,
        validator: (value) {
          if(value!.isEmpty || value == ""){
            return "Email can't be empty";
          }else if(!value.trim().contains("@")){
            return "Email not valid";
          }
          return null;
        },
        onSaved: (value) {
          loadAuth.enteredEmail = value!;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          hintText: "Insert Email...."
        ),
      ),
    )
  ],
);

  }
}