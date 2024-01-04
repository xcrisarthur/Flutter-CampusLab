import 'package:flutter/material.dart';
import 'package:flutter_uilogin/domain/usecases/AuthUsecase.dart';
// import 'package:flutter_uilogin/widget/imgpick/imgpick_widget.dart';
import 'package:flutter_uilogin/presentation/widgets/textfield/TextFieldEmailWidget.dart';
import 'package:flutter_uilogin/presentation/widgets/textfield/TextFieldPassWidget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var loadAuth = Provider.of<AuthProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: loadAuth.form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    loadAuth.islogin?"L O G I N" : "R E G I S T E R",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.fontSize),
                  ),
                ),
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextfieldEmailWidget(controller: email),
                      const SizedBox(
                        height: 30,
                      ),
                      TextfieldPasswordWidget(controller: password),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: ElevatedButton(onPressed: (){
                          loadAuth.submit();
                        }, child: Text(loadAuth.islogin ? "Login" : "Register")),
                      ),
                      const SizedBox(height: 20,),
                      Center(
                        child: TextButton(onPressed: (){
                          setState(() {
                            loadAuth.islogin = !loadAuth.islogin;
                          });
                        }, child: Text(loadAuth.islogin ? "Create account" : "I already have account")),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}