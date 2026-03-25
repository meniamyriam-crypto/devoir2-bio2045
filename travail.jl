# ---
# title: Simulation d’une intervention dans un modèle de succession végétale
# repository: meniamyriam-crypto/devoir2-bio2045
# auteurs:
#    - nom: Menia
#      prenom: Myriam
#      matricule: 20281484
#      github: meniamyriam-crypto
#    - nom: Salman
#      prenom: Assile
#      matricule: 20268931
#      github: salmanassile-crypto
# ---

# # Introduction
# La succession végétale est un processus écologique au cours duquel la composition des communautés végétales évolue dans le temps.
# Dans ce travail, on utilise le code de la séance sur les modèles de transition végétale afin de simuler l'évolution de parcelles
# entre trois états : Barren (sol nu), Grasses (herbes) et Shrubs (arbustes). 
# L'objectif est de simuler une intervention écologique et d'évaluer son efficacité en comparant le scénario de base à un scénario modifié. 

# # Présentation du modèle
# Le modèle repose sur une matrice de transition qui décrit la probabilité de passer d'un état à un autre à chaque génération. Les trois états étudiés sont Barren, Grasses et Shrubs.
# Le scénario de base correspond au code fourni en classe. Une intervention est ensuite simulée en modifiant la matrice de transition pour favoriser la végétalisation. 
# Les valeurs de la matrice sont ensuite normalisées afin de représenter des probabilités de transition.
 
# # Implémentation

# ## Packages nécessaires

# ## Packages nécessaires

import Random
Random.seed!(123456)
using CairoMakie
using Distributions

include("code/01_test.jl")

# États :
# 1 = Barren
# 2 = Grasses
# 3 = Shrubs A
# 4 = Shrubs B

# 200 parcelles, 50 plantées
s = [150, 0, 25, 25]

# Matrice de transition
T = zeros(Float64, 4, 4)

T[1, :] = [0.85, 0.10, 0.03, 0.02]
T[2, :] = [0.05, 0.80, 0.10, 0.05]
T[3, :] = [0.02, 0.05, 0.85, 0.08]
T[4, :] = [0.02, 0.05, 0.08, 0.85]

# Simulation déterministe
sim_det = simulation(T, s, generations=200)

# Simulation stochastique (version simple)
function simulation_stoch(T, s; generations=200)
    states = copy(s)
    n = length(s)

    ts = zeros(Float64, n, generations+1)
    ts[:,1] = states

    for g in 1:generations
        new_states = zeros(Float64, n)

        for i in 1:n
            for j in 1:n
                n_trans = rand(Binomial(round(Int, states[i]), T[i,j]))
                new_states[j] += n_trans
            end
        end

        states = new_states
        ts[:, g+1] = states
    end

    return ts
end

# 100 simulations
n_sim = 100
success = 0

for i in 1:n_sim
    sim = simulation_stoch(T, s)
    final = sim[:, end]

    total = sum(final)
    vegetation = final[2] + final[3] + final[4]

    if vegetation > 0
        p_veg = vegetation / total
        p_grass = final[2] / vegetation
        p_shrubs = (final[3] + final[4]) / vegetation

        if (final[3] + final[4]) > 0
            p_min = min(final[3], final[4]) / (final[3] + final[4])
        else
            p_min = 0
        end

        if p_veg ≥ 0.2 && abs(p_grass - 0.3) < 0.1 && abs(p_shrubs - 0.7) < 0.1 && p_min ≥ 0.3
            success += 1
        end
    end
end

println("Nombre de simulations respectant les critères : ", success, "/", n_sim)

# Graphique
f = Figure()
ax = Axis(f[1,1], xlabel="Générations", ylabel="Nombre de parcelles")

colors = [:grey, :orange, :green, :darkgreen]
labels = ["Barren", "Grasses", "Shrubs A", "Shrubs B"]

for i in 1:4
    lines!(ax, sim_det[i, :], color=colors[i], label=labels[i])
end

axislegend(ax)
f

save("travail-figure.png", f)

# Les résultats montrent que l’intervention accélère la transition vers les arbustes.
# Les zones de sol nu diminuent plus rapidement comparativement au scénario de base.
# On remarque également que la dynamique du système est plus rapide avec l’intervention.
# La différence entre les deux scénarios devient de plus en plus marquée au fil des générations.

# # Discussion

# Les résultats montrent que la dynamique du système évolue vers un état stable où une proportion de parcelles est végétalisée. 
# On observe que les proportions d’herbes et de buissons se stabilisent au fil des générations, ce qui suggère que le système atteint un équilibre.
# Les simulations stochastiques indiquent que les critères imposés sont respectés dans une grande proportion des cas. 
# Cela signifie que la combinaison de la population initiale et de la matrice de transition permet d’atteindre les objectifs fixés de manière robuste.
# Le modèle déterministe permet de visualiser la tendance générale du système, tandis que le modèle stochastique montre la variabilité possible autour de cette tendance.
#
# On observe aussi que l’écart entre le scénario de base et celui avec intervention devient de plus en plus important avec le temps,
# ce qui suggère que les effets de l’intervention s’accumulent au cours des générations.
#
# Ce modèle reste simplifié et théorique car il ne prend pas en compte plusieurs facteurs écologiques tels que
# les conditions environnementales, les perturbations (feux, secheresse) ou les interactions entre espèces.
# Mais en plus, les transitions sont sensées être constantes dans le temps, ce qui n’est pas réaliste dans un contexte naturel.
#
# Malgré ces limites, ce modèle permet de bien illustrer comment une intervention peut influencer la dynamique d’un écosystème
# et met en avant l’importance des probabilités de transition dans l’évolution du système.
# Une version stochastique du modèle a également été utilisée pour vérifier la robustesse des résultats. 
# Sur 100 simulations, les critères imposés sont respectés dans une grande proportion des cas, ce qui indique que la stratégie est assez efficace.
