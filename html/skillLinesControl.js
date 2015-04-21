var skillList = angular.module('SkillLines', ['ui.bootstrap', 'ngSanitize', 'angularBootstrapNavTree'])
.controller('SkillLineControl', ['$scope', function ($scope, $http) {
	$scope.setSkills = function() {
		$scope.skills = this.data.skills
	}
	
	$scope.openBranch = function(branch) {
		$scope.linesTree.collapse_all()
		branch.expanded = true
	}
	
    
	$http.get('skilldata.json')
		.then(function(res) {
			$scope.skillTypes = res.data.lines;
			$scope.buildTree(res.data.lines);
		});
}])
;