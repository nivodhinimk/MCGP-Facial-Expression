function bestFeatures = mcgpopti(features, labels, numIndividuals, numGenerations)
rng(10)
       population = randi([0 1], numIndividuals, size(features, 2)); 
    bestFeatures = [];

    for gen = 1:numGenerations
        
        fitness = zeros(numIndividuals, 1);
        for i = 1:numIndividuals
            selectedFeatures = features(:, logical(population(i, :)));
            if ~isempty(selectedFeatures)
                classifier = fitcecoc(selectedFeatures, labels);
                cv = crossval(classifier);
                fitness(i) = 1 - kfoldLoss(cv); 
            else
                fitness(i) = 0; 
            end
        end
        
        
        [~, idx] = sort(fitness, 'descend');
        nextPopulation = population(idx(1:round(numIndividuals/2)), :);
        
        
        for i = 1:round(numIndividuals/4)
            parent1 = nextPopulation(randi(size(nextPopulation, 1)), :);
            parent2 = nextPopulation(randi(size(nextPopulation, 1)), :);
            crossoverPoint = randi(size(parent1, 2));
            child1 = [parent1(1:crossoverPoint), parent2(crossoverPoint+1:end)];
            child2 = [parent2(1:crossoverPoint), parent1(crossoverPoint+1:end)];
            nextPopulation = [nextPopulation; child1; child2];
        end
        
        
        mutationRate = 0.01;
        for i = 1:size(nextPopulation, 1)
            if rand < mutationRate
                mutationPoint = randi(size(nextPopulation, 2));
                nextPopulation(i, mutationPoint) = ~nextPopulation(i, mutationPoint);
            end
        end
        
        population = nextPopulation(1:numIndividuals, :); 
        gen
    end
         
    bestIndividual = population(1, :);
    bestFeatures = features(:, logical(bestIndividual));
end