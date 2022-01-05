global class AuthProviderRegHandler implements Auth.RegistrationHandler {

  global User createUser(Id portalId, Auth.UserData data){
    List<User> users = [SELECT ID FROM User Where Email = : data.email];
    User user = null;
    // at the moment, the code is only for
    // authorizing the org-to-org connection
    // so this should be sufficient enough
    if(users.size() > 0){
      user = users[0];
    }
    return user;
  }

  global void updateUser(Id userId, Id portalId, Auth.UserData data){
    // do nothing
  }
}