String appAuthException({required String codeerror}) {
  switch (codeerror) {
    case "email-already-exists":
      return "Email already exists. Try agin with another";

    case "id-token-expired":
      return "The token ID has been expired.";

    case "internal-error":
      return "An internal server error occured.";

    case "invalid-password":
      return "The password you entered is invalid. Should be more than 6 characters.";

    case "ERROR_TOO_MANY_REQUESTS":
      return "Too many requests. Try again later.";

    case "user-not-found":
      return "No user with these details exists.";

    case "invalid-email":
      return "User with this email doesn't exist.";

    case "wrong-password":
      return "The password you entered is incorect.";

    case "network-request-failed":
      return "Try connecting to network.";

    default:
      return "An undefined Error happened.";
  }
}
