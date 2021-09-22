import 'package:mysql1/mysql1.dart';
import 'dart:io';


Future main() async {
  final conn = await MySqlConnection.connect(ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'cpifpe',
    password: 'root000'));
    await Future.delayed(Duration(seconds: 1));

  print('----- BEM VINDO AO CENTRO DE PESQUISA -----');

  print('''O que você deseja fazer?
[ 1 ] - Realizar Login
[ 2 ] - Realizar Cadastro (Apenas administradores)
[ 0 ] - Sair''');

  stdout.write('> ');
  int escolha = int.parse(stdin.readLineSync()!);

  if (escolha == 1) {
    print('''Você deseja realizar login como Administrador, Professor ou Aluno?
[ 1 ] - Administrador
[ 2 ] - Professor
[ 3 ] - Aluno''');
    stdout.write('> ');
    int escolha = int.parse(stdin.readLineSync()!);

    if (escolha == 1 || escolha == 2) {
      stdout.write('Seu login do IFPE: ');
      String login = stdin.readLineSync()!.trim();
      stdout.write('Senha: ');
      String senha = stdin.readLineSync()!.trim();

      //* Verificando se existe alguém com o login informado:
      int quantidade = 0;

      if (escolha == 1) {
        var results = await conn.query(
          'SELECT COUNT(*) FROM administrador WHERE login = ?', [login]
        );
        for (var row in results)
          quantidade = row[0];
      }

      else if (escolha == 2) {
        var results = await conn.query(
          'SELECT COUNT(*) FROM professor WHERE login = ?', [login]
        );
        for (var row in results)
          quantidade = row[0];
      }

      if (quantidade == 0)
        print('Não existe nenhum usuário cadastrado no Centro de Pesquisas com esse login!');
      else
        print('Login realizado com sucesso!');

        if (escolha == 1) {
          print('''O que você deseja fazer? 
[ 1 ] - Cadastrar Usuário
[ 2 ] - Descadastrar Usuário
[ 3 ] - Visualizar Histórico de Entradas e Saídas''');
        }
        stdout.write('> ');
        escolha = int.parse(stdin.readLineSync()!);

        if (escolha == 1) {
          print('''Você deseja cadastrar um professor ou um aluno?
[ 1 ] - Professor
[ 2 ] - Aluno''');
          stdout.write('> ');
          escolha = int.parse(stdin.readLineSync()!);

          //* Cadastrando Professor:
          if (escolha == 1) {
            stdout.write('Nome: ');
            String nome = stdin.readLineSync()!.trim();

            stdout.write('Login do IFPE: ');
            String login = stdin.readLineSync()!.trim();

            stdout.write('Senha: ');
            String senha = stdin.readLineSync()!.trim();
            
            stdout.write('Sala: ');
            String id_sala = stdin.readLineSync()!.trim();

            var result = await conn.query(
              'insert into professor(nome, login, senha, id_sala) values(?, ?, ?, ?)',
              [nome, login, senha, id_sala]);
            print('Cadastro realizado com sucesso!');
          }

          //* Cadastrando Aluno:
          else if (escolha == 2) {
            stdout.write('Nome: ');
            String nome = stdin.readLineSync()!.trim();

            stdout.write('Matrícula do IFPE: ');
            String matricula = stdin.readLineSync()!.trim();

            stdout.write('Senha: ');
            String senha = stdin.readLineSync()!.trim();
            
            stdout.write('Sala: ');
            String id_sala = stdin.readLineSync()!.trim();

            var result = await conn.query(
              'insert into professor(nome, matricula, senha, id_sala) values(?, ?, ?, ?)',
              [nome, matricula, senha, id_sala]);
            print('Cadastro realizado com sucesso!');
          }
        }

          else if (escolha == 2) {
            print('''Você deseja descadastrar um Professor ou um Aluno?
[ 1 ] - Professor
[ 2 ] - Aluno''');
            stdout.write('> ');
            escolha = int.parse(stdin.readLineSync()!);
          }
    }

    if (escolha == 3) {
      stdout.write('Sua matrícula no IFPE: ');
      String matricula = stdin.readLineSync()!.trim();
      stdout.write('Senha: ');
      String senha = stdin.readLineSync()!.trim();

      //* Verificando se existe alguém com a matrícula informada:
      var results = await conn.query(
        'SELECT COUNT(*) FROM aluno WHERE matricula = ?', [matricula]
      );
      int quantidade = 0;
      for (var row in results)
        quantidade = row[0];

      if (quantidade == 0)
        print('Não existe nenhum aluno cadastrado no Centro de Pesquisas com essa matrícula!');
    }
  }

  else if (escolha == 2) {
    print('-' * 40);

    stdout.write('Nome: ');
    String nome = stdin.readLineSync()!.trim();

    stdout.write('Login do IFPE: ');
    String login = stdin.readLineSync()!;

    stdout.write('Senha (max: 12 caracteres): ');
    String senha = stdin.readLineSync()!;

    // Inserindo dados na tabela
    var result = await conn.query(
      'insert into administrador(nome, login, senha) values(?, ?, ?)',
      [nome, login, senha]);
    print('Cadastro realizado com sucesso!');
  }

  else if (escolha == 3) {

  }

/* Criação de tabelas:
await conn.query('''CREATE TABLE administrador (
  nome varchar(40) NOT NULL,
  login varchar(15),
  senha varchar(12) NOT NULL,
  primary key (login)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;''');

await conn.query('''CREATE TABLE professor (
  nome varchar(40) NOT NULL,
  login varchar(15),
  login_adm varchar(15),
  senha varchar(12) NOT NULL,
  id_sala varchar(5) NOT NULL,
  primary key (login),
  foreign key (login_adm) references administrador (login)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;''');

await conn.query('''CREATE TABLE aluno (
  nome varchar(40) NOT NULL,
  matricula varchar(15),
  login_adm varchar(15),
  senha varchar(12) NOT NULL,
  id_sala varchar(5) NOT NULL,
  primary key (matricula),
  foreign key (login_adm) references administrador (login)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;''');

await conn.query('''CREATE TABLE entrada (
  data date NOT NULL,
  horario time NOT NULL,
  matricula_aluno varchar(15),
  login_prof varchar(15),
  foreign key (matricula_aluno) references aluno (matricula),
  foreign key (login_prof) references professor (login)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;''');

await conn.query('''CREATE TABLE saida (
  data date NOT NULL,
  horario time NOT NULL,
  matricula_aluno varchar(15),
  login_prof varchar(15),
  foreign key (matricula_aluno) references aluno (matricula),
  foreign key (login_prof) references professor (login)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;'''); */
  await conn.close();
}
