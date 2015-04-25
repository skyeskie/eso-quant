var SkillData = angular.module('SkillsList', ['ui.bootstrap', 'ngSanitize', 'angularBootstrapNavTree', 'lvl.directives.dragdrop']);
SkillData.controller('SkillMainDataController', ['$scope', '$http', function ($scope, $http) {
	$scope.skills = []
	$scope.rawSkills = []
	$scope.rawLineData = {}
	$scope.rawSkillData = {}
	$scope.skillNames = []
	
	$scope.buildSkillList = function(skillTable) {
		$scope.rawSkillData = skillTable;
		$scope.rawSkills = [];
		for( v in skillTable) {
			$scope.rawSkills.push(skillTable[v]);
		}
	}
	
	$scope.setSkills = function() {
		$scope.skillNames = this.data.skills
	}

	$http.get('skilldata.json')
		.then(function(res) {
			$scope.buildSkillList(res.data.skills);
			$scope.rawLineData = res.data.lines;
		});
}]);
SkillData.controller('SkillListController', ['$scope', function($scope) {
	$scope.currentPage=1
	$scope.numPerPage=5
	$scope.maxSize=5
	$scope.$watch("currentPage + numPerPage", function() {
		var begin = (($scope.currentPage - 1) * $scope.numPerPage),
			end = begin + $scope.numPerPage;
		$scope.skills = $scope.rawSkills.slice(begin, end);
	});
	
	$scope.$watch("skillNames", function(names) {
		if(names.length == 0) return;
		var skillObjs = []
		var obj
		for(k in names) {
			skillObjs.push($scope.rawSkillData[names[k]]);
		}
		$scope.skills = skillObjs;
	});
}]);
SkillData.controller('SkillLineController', ['$scope', function ($scope) {
	$scope.skillLineTree = []
	$scope.linesTree = {};
	$scope.$watch("rawLineData", function() {
		var data = $scope.rawLineData
		$scope.skillLineTree = []
		for(i in data) {
			var skillLines = data[i]
			line = {
				onSelect: $scope.openBranch,
				label: i,
				children: []
			}
			for(j in skillLines) {
				line.children.push({
					label: j.replace("'",""),
					onSelect: $scope.setSkills,
					data: { skills: skillLines[j] }	
				})
			}
			$scope.skillLineTree.push(line)
		}
	});
	
	$scope.openBranch = function(branch) {
		$scope.linesTree.collapse_all()
		branch.expanded = true
	}
}]);
SkillData.controller('LoadoutController', ['$scope', function ($scope) {
	$scope.emptySkill = {
		name: "",
		description: "",
		cost: 0,
		target: "",
		mechanic: "",
		castTime: 0,
		channelTime: 0,
		durationMS: 0,
		distance: 0,
		maxRange: 0,
		radius: 0,
		fit: []
	}
	$scope.skills = []
	$scope.updaters = []
	for(var i=0; i<12; ++i) {
		$scope.skills[i] = angular.copy($scope.emptySkill)
	}
	$scope.dropped = function(dragID, index, dropID) {
	  index = Number(index)
	  var drag = angular.element(document.getElementById(dragID));
	  var targetSkill = $scope.skills[index]
	  angular.copy($scope.rawSkillData[drag.attr("data-skill")], targetSkill)
	  $scope.$apply()
	  //var scope = document.getElementById(dropID).getElementsByTagName("skill-info-full")[0].scope()
	  //angular.copy($scope.rawSkillData[drag.text()], scope.skill)
    };
	$scope.defined = function(v) {
		return v.name != ""
	}
	$scope.haveValues = true
	$scope.magicka = 15000
	$scope.stamina = 15000
	$scope.health = 15000
	$scope.spellpower = 1200
	$scope.weaponpower = 1200
	$scope.calc = function(fit, type) {
		var main = 0
		var power = 0
		switch(type) {
			case 'Magicka':
				main = $scope.magicka
				power = $scope.spellpower
				break
			case 'Stamina':
				main = $scope.stamina
				power = $scope.weaponpower
				break
			case 'Ultimate':
				main = Max($scope.magicka, $scope.stamina)
				power = Max($scope.spellpower, $scope.weaponpower)
		}
		return Math.round(main*fit.mainCoef + power*fit.powerCoef + $scope.health*fit.healthCoef + fit.intercept)
	}
}]);
SkillData.filter('fitQualityClass', function() {
  return function(input) {
	input == input || 0
	if(input > 0.999) {
		return 'label-success';
	} else if(input > 0.9) {
		return 'label-warning';
	} else {
		return 'label-danger';
	}
  }
});
SkillData.filter('resource',function() {
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
  }
});
SkillData.filter('fID', function() {
	return function(input) {
		input = input || '';
		return input.replace(/(##f[0-9]+##)/g,'<span class="formulaID">$1</span>');
	}
});
SkillData.filter('divide', function() {
	return function(input, amount) {
		return Number(input) / Number(amount);
	}
});
SkillData.filter('nl2br', function() {
	return function(input) {
		input = input || '';
		return input.replace(/\n/g,'<br />');
	}
});
SkillData.directive('skillDesc', function() {
	return {
		restrict: 'E',
		controller: function($scope, $element) {
			$scope.$watch("skill.description", function(newVal) {
				var desc = newVal
				desc = desc.replace(/\n/g,'<br />')
				desc = desc.replace(/(##f[0-9]+##)/g,'<span class="formulaID">$1</span>');
				desc = desc.replace(/Flame Damage/g, '<span class="label dmg-flame">Flame Damage</span>')
				desc = desc.replace(/Magic Damage/g, '<span class="label dmg-magic">Magic Damage</span>')
				desc = desc.replace(/Ice Damage/g, '<span class="label dmg-ice">Ice Damage</span>')
				desc = desc.replace(/Cold Damage/g, '<span class="label dmg-ice">Cold Damage</span>')
				desc = desc.replace(/Shock Damage/g, '<span class="label dmg-shock">Shock Damage</span>')
				desc = desc.replace(/Poison Damage/g, '<span class="label dmg-poison">Poison Damage</span>')
				desc = desc.replace(/Disease Damage/g, '<span class="label dmg-disease">Disease Damage</span>')
				desc = desc.replace(/Physical Damage/g, '<span class="label dmg-physical">Physical Damage</span>')
				$element.html(desc)
			})
		}
	};
});

SkillData.directive('skillFull', function() {
	return {
		restrict: 'E',
		scope: {
			skill: '=info',
		},
		templateUrl: 'skill-template.html',
		link: function(scope, element, attrs) {
			scope.description = scope.skill.description
			scope.calc = scope.$parent.calc
		}
	}
});

SkillData.directive('formulaPart', function() {
  return {
	  restrict: 'E',
	  scope: {
		  label: '@',
		  value: '@'
	  },
	  template: '<span ng-show="{{value > 0.0001}}"><span class="coef">{{value}}</span> &times; <span class="var">{{label}}</span> +</span>'
  }
})

SkillData.directive("rsq", function() {
	return {
		scope: {
			rsqValue: '=value',
		},
		template: '<span class="rsq label {{fitQualityClass}}">{{rsqValue|number:4}}</span>'
	}
});

SkillData.directive('skillInfo', function() {
  return {
	  restrict: 'E',
	  scope: {
		  label: '@',
		  value: '@',
		  suffix: '@'
	  },
	  template: '<div class="info" ng-show="value > 0"><b>{{label}}:</b> {{value}}{{suffix}}</div>'
  }
})