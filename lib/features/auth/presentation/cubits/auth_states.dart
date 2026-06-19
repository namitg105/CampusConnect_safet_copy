/*
Auth States
 */

import 'package:noteswap/features/auth/domain/entities/app_user.dart';

abstract class AuthState{}

//initial 
class AuthInitial extends AuthState{}

//loading...
class AuthLoading extends AuthState{}

//Authenticated
class Authenticated extends AuthState{
//if its an Authenticated , then we should have  a user that is logged in 
final AppUser user;

  Authenticated( this.user);

}

//Unauthenticated
class Unauthenticated extends AuthState{}

//errors..
class AuthError extends AuthState{
  final String message;
  AuthError(this.message);
}