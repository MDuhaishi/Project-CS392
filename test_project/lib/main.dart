import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MathGameApp());
}

class MathGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => GameMenuPage(name: emailController.text)),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content:
              Text("Failed to sign in. Please check your email and password."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسجيل الدخول'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => signIn(context),
                child: Text('تسجيل الدخول'),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ),
                  );
                },
                child: Text('إنشاء حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> signUp(BuildContext context) async {
    if (passwordController.text == confirmPasswordController.text) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        await userCredential.user!.updateDisplayName(nameController.text);
        await userCredential.user!.reload();
        User? updatedUser = FirebaseAuth.instance.currentUser;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GameMenuPage(name: updatedUser!.displayName ?? 'User'),
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Registration Error'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('The passwords do not match.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('انشاء حساب'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration:
                    InputDecoration(labelText: 'الاسم الذي يظهر في اللعبة'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'تأكيد كلمة المرور'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => signUp(context),
                child: Text('إنشاء حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameMenuPage extends StatefulWidget {
  final String name;

  GameMenuPage({required this.name});

  @override
  _GameMenuPageState createState() => _GameMenuPageState();
}

class _GameMenuPageState extends State<GameMenuPage> {
  //Fixing soundtrack
  // AudioPlayer audioPlayer = AudioPlayer();

  // @override
  // void initState() {
  //   super.initState();
  //   playLocal();
  // }

  // void playLocal() async {
  //   await audioPlayer.setReleaseMode(ReleaseMode.loop);
  //   await audioPlayer.play(AssetSource('images/music_sound.mp3'));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة اللعبة'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('مرحباً, ${widget.name}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the actual game page
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => GamePage()));
              },
              child: Text('العب الآن'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to settings page
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
              child: Text('الإعدادات'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // audioPlayer.dispose();
    super.dispose();
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int remainingAttempts = 3;
  int currentLevel = 1;
  int score = 0;
  List<Question> questions = [
    Question('ما هو ناتج 2 + 2؟', ['3', '4', '5', '6'], 1),
    Question('ما هو ناتج 10 - 5؟', ['3', '4', '5', '6'], 2),
    Question('ما هو ناتج 2 * 4؟', ['10', '8', '6', '1'], 1),
    Question('ما هو ناتج 24 / 2؟', ['4', '13', '11', '12'], 3),
    Question('ما هو ناتج 5 + (24 / 2)؟', ['9', '13', '11', '17'], 3),
    Question('ما هو ناتج (5 + 9) / 2 ؟', ['3', '7', '14', '9'], 1),
    Question('ما هو ناتج (10 / 2) + 5؟', ['16', '13', '6', '10'], 3),
  ];

  void handleAnswer(int selectedAnswerIndex) {
    if (questions[currentLevel - 1].correctAnswerIndex == selectedAnswerIndex) {
      setState(() {
        score += 1;
      });

      if (currentLevel == questions.length) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('انتهت اللعبة!'),
              content: Text('لقد انهيت جميع المراحل. النقاط: $score'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('اغلاق'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('اجابة صحيحة'),
              content: Text(
                  'احسنت! يمكنك المتابعة الى المرحلة التالية. النقاط: $score'),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      currentLevel++;
                      remainingAttempts = 3;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('التالي'),
                ),
              ],
            );
          },
        );
      }
    } else {
      setState(() {
        remainingAttempts--;
      });

      if (remainingAttempts == 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('اجابة خاطئة!'),
              content: Text('لاتقلق يمكنك المحاولة مره اخرى. النقاط: $score'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      currentLevel = 1;
                      score = 0;
                      remainingAttempts = 3;
                    });
                  },
                  child: Text('اغلاق'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('اجابة خاطئة!'),
              content: Text(
                  'لم تحزر الإجابة. لديك $remainingAttempts محاولات متبقية.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('اغلاق'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المرحلة $currentLevel'),
      ),
      body: Column(
        children: [
          ScoreBar(currentLevel: currentLevel, score: score),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: AssetImage('images/character_cat.png')),
                    Text(
                      questions[currentLevel - 1].questionText,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 20.0),
                    ...questions[currentLevel - 1]
                        .choices
                        .asMap()
                        .entries
                        .map((entry) {
                      int idx = entry.key;
                      String val = entry.value;
                      return ElevatedButton(
                        onPressed: () => handleAnswer(idx),
                        child: Text(val),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreBar extends StatelessWidget {
  final int currentLevel;
  final int score;

  ScoreBar({required this.currentLevel, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.yellow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'المرحلة $currentLevel',
            style: TextStyle(color: Colors.black),
          ),
          Text(
            'النقاط: $score',
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class Question {
  String questionText;
  List<String> choices;
  int correctAnswerIndex;

  Question(this.questionText, this.choices, this.correctAnswerIndex);
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات الصوت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('تشغيل/إيقاف الموسيقى'),
              value: true,
              onChanged: (bool value) {},
            ),
            const Divider(),
            const Text(
              'تغيير المعلومات الشخصية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('تغيير البريد الإلكتروني'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeEmail(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('تغيير اسم المستخدم'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNameDialog(),
                  ),
                );
              },
            ),
            const Divider(),
            const Text(
              'تغيير كلمة المرور',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('تغيير كلمة المرور'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeEmail extends StatelessWidget {
  final TextEditingController currentEmailController = TextEditingController();
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: currentEmailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني الحالي',
                ),
              ),
              TextField(
                controller: newEmailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني الجديد',
                ),
              ),
              TextField(
                controller: confirmEmailController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد البريد الإلكتروني',
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  String currentEmail = currentEmailController.text;
                  String newEmail = newEmailController.text;
                  String confirmEmail = confirmEmailController.text;
                  String password = passwordController.text;

                  currentEmailController.clear();
                  newEmailController.clear();
                  confirmEmailController.clear();
                  passwordController.clear();
                },
                child: const Text('تغيير البريد الإلكتروني'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير كلمة المرور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور القديمة',
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('تأكيد التغيير'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeNameDialog extends StatelessWidget {
  final TextEditingController newNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تغيير اسم المستخدم'),
      content: TextField(
        controller: newNameController,
        decoration: const InputDecoration(
          labelText: 'اسم المستخدم الجديد',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            String newUserName = newNameController.text;
            Navigator.pop(context);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
