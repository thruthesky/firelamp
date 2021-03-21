import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  RegisterForm({this.onPressed});

  final Function onPressed;

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: email,
          decoration: InputDecoration(hintText: '이메일 주소를 입력하세요.'),
        ),
        TextFormField(
          controller: password,
          decoration: InputDecoration(hintText: '비밀번호를 입력하세요.'),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onPressed(email.text, password.text),
            child: Text('회원 가입'),
          ),
        ),
      ],
    );
  }
}
