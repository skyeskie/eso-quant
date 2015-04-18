var skillList = angular.module('SkillsList', ['ui.bootstrap', 'ngSanitize'])
.controller('SkillListControl', function ($scope, $http) {
	$scope.skills = []
	$scope.currentPage=1
	$scope.numPerPage=10
	$scope.maxSize=5
	$scope.rawSkills = []
	
	$scope.$watch("currentPage + numPerPage", function() {
		var begin = (($scope.currentPage - 1) * $scope.numPerPage),
			end = begin + $scope.numPerPage;
		$scope.skills = $scope.rawSkills.slice(begin, end);
	})
	
	$scope.buildSkillList = function(skillTable) {
		$scope.rawSkills = [];
		for( v in skillTable) {
			$scope.rawSkills.push(skillTable[v]);
		}
		$scope.skills = $scope.rawSkills.slice(0, $scope.numPerPage);
	}
	
	$http.get('skilldata.json')
		.then(function(res) {
			$scope.buildSkillList(res.data.skills);
			$scope.lines = res.data.lines;
		});
})
.filter('info', function() {
  return function(input, label, suffix) {
	if(input == '' || input == 0) { return ''; }
	return "<div class='info'><b>" + label + "</b> " + input + suffix + "</div>";
  };
})
.filter('fitQualityClass', function() {
  return function(input) {
	input == input || 0
	if(input > 0.999) {
		return 'label-success';
	} else if(input > 0.9) {
		return 'label-warning';
	} else {
		return 'label-danger';
	}
  };
})
.filter('resource',function() {
  return function(input, label, suffix) {
	if(input == '' || input == 0) { return ''; }
	switch(input) {
		case 'Stamina':
			return '<span class="stam">Stamina</span>';
		case 'Magicka':
			return '<span class="magk">Magicka</span>';
		case 'Ultimate':
			return '<span class="ultm">Ultimate</span>';
		case 'Health':
			return '<span class="health">Health</span>';
		default:
			return input;
	}
  };
})
.filter('fID', function() {
	return function(input) {
		input = input || '';
		return input.replace(/(##f[0-9]+##)/,'<span class="formulaID">$1</span>');
	}
})
.filter('nl2br', function() {
	return function(input) {
		input = input || '';
		return input.replace(/\n/,'<br />');
	}
})
.directive("skill-desc", function() {
	function sanitize(scope, element, attrs) {
		element.html(attrs.skill-desc.replace(/\n/,'<br />'))
	}
	return {
		transclude: true,
		link: sanitize
	};
})
.directive("rsq", function() {
	return {
		scope: {
			rsqValue: '=value',
		},
		template: '<span class="rsq label {{fitQualityClass}}">{{rsqValue|number:4}}</span>'
	}
})
;