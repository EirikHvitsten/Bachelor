
class DecisionTree {

	function firstDecTree(list){
		if (list[0] <= 2.0){
			if (list[2] <= -1.5){
				if (list[0] <= -1.5){
					System.println("weights: [1.00, 0.00, 0.00] class: lysegraa");
					treeGroup = skrivGruppe(lightgrey);
				}else {
					System.println("weights: [0.00, 2.00, 0.00] class: moerkegraa");
					treeGroup = skrivGruppe(darkgrey);
				}
			}else {
				if (list[1] <= 1.5){
					if (list[0] <= -0.5){
						System.println("weights: [0.00, 0.00, 3.00] class: svart");
						treeGroup = skrivGruppe(black);
					}else {
						if (list[1] <= -0.5){
							System.println("weights: [0.00, 2.00, 0.00] class: moerkegraa");
							treeGroup = skrivGruppe(darkgrey);
						}else {
							if (list[4] <= -1.0){
								System.println("weights: [1.00, 0.00, 0.00] class: lysegraa");
								treeGroup = skrivGruppe(lightgrey);
							}else {
								System.println("weights: [0.00, 0.00, 2.00] class: svart");
								treeGroup = skrivGruppe(black);
							}
						}
					}
				}else {
					System.println("weights: [0.00, 1.00, 0.00] class: moerkegraa");
					treeGroup = skrivGruppe(darkgrey);
				}
			}
		}else {
			System.println("weights: [3.00, 0.00, 0.00] class: lysegraa");
			treeGroup = skrivGruppe(lightgrey);
		}
	}
	
	function secondDecTree(list){
		if (list[10] <= 0.5){
			if (list[5] <= -0.5){
				if (list[5] <= -2.5){
					if (list[6] <= -1.0){
						System.println("weights: [1.00, 0.00, 0.00] class: lysegraa");
						treeGroup = skrivGruppe(lightgrey);
					}else {
						System.println("weights: [0.00, 0.00, 1.00] class: svart");
						treeGroup = skrivGruppe(black);
					}
				}else {
					if (list[1] <= -1.5){
						if (list[4] <= -1.5){
							System.println("weights: [0.00, 1.00, 0.00] class: moerkegraa");
							treeGroup = skrivGruppe(darkgrey);
						}else {
							System.println("weights: [0.00, 0.00, 1.00] class: svart");
							treeGroup = skrivGruppe(black);
						}
					}else {
						System.println("weights: [0.00, 4.00, 0.00] class: moerkegraa");
						treeGroup = skrivGruppe(darkgrey);
					}
				}
			}else {
				System.println("weights: [0.00, 0.00, 3.00] class: svart");
				treeGroup = skrivGruppe(black);
			}
		}else {
			System.println("weights: [4.00, 0.00, 0.00] class: lysegraa");
			treeGroup = skrivGruppe(lightgrey);
		}
	}
	
	function thirdDecTree(list){
		if (list[10] <= 0.5){
			if (list[12] <= -1.5){
				if (list[8] <= -2.5){
					System.println("weights: [1.00, 0.00, 0.00] class: lysegraa");
					treeGroup = skrivGruppe(lightgrey);
				}else {
					System.println("weights: [0.00, 4.00, 0.00] class: moerkegraa");
					treeGroup = skrivGruppe(darkgrey);
				}
			}else {
				if (list[10] <= -2.5){
					System.println("weights: [0.00, 1.00, 0.00] class: moerkegraa");
					treeGroup = skrivGruppe(darkgrey);
				}else {
					System.println("weights: [0.00, 0.00, 5.00] class: svart");
					treeGroup = skrivGruppe(black);
				}
			}
		}else {
			System.println("weights: [4.00, 0.00, 0.00] class: lysegraa");
			treeGroup = skrivGruppe(lightgrey);
		}
	}
}