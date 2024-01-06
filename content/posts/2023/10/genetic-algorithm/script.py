def crossover(self, mixinInd, rate_prop):
    # to crossover features between tanks, take randomely a tank from one individual and the other tank from mix in individual
    rand_tank_list = deepcopy(list(self.tank_list[:-1]))
    rand.shuffle(rand_tank_list)
    for i in range(int(len(rand_tank_list) * rate_prop)):
        tank = rand_tank_list[i]
        choice = random.choice(["self", "other"])
        if choice == "other":
            # print(f"Crossover {tank} - {choice}")
            old_tank = self.state[self.tank2indice[tank]]
            new_tank = mixinInd.state[mixinInd.tank2indice[tank]]
            diff_quantities = old_tank - new_tank
            projected_warehouse = (
                self.state[self.tank2indice["warehouse"]] + diff_quantities
            )
            # print(f"New {new_tank} - Old {old_tank} - Diff {diff_quantities} - WH {projected_warehouse}")
            # above zero constraint
            test_above_zero = projected_warehouse >= np.zeros(
                (1, len(projected_warehouse))
            )
            test_below_capa = projected_warehouse.sum() < self.capacity["warehouse"]
            if test_above_zero.all() and test_below_capa:
                self.state[self.tank2indice[tank]] = new_tank
                self.state[self.tank2indice["warehouse"]] = projected_warehouse
