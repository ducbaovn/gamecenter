ChatRoom.directive 'userPanel', [
  '$rootScope', 
  '$sails', 
  'CurrentUser', 
  ($rootScope, $sails, CurrentUser)->
    tmpl = 
      restrict: 'E'
      templateUrl: 'templates/user_panel.html'
      controller: ($scope)->
        $scope.CurrentUser = CurrentUser
        $scope.loginWithToken = ()=>
          CurrentUser.auth()

    return tmpl

  ]