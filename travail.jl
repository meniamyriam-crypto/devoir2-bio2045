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
#      matricule: XXXXXXXX
#      github: salmanassile-crypto
# ---

# # Introduction
# La succession végétale est un processus écologique au cours duquel la composition des communautés végétales évolue dans le temps.
# Dans ce travail on utilise le code de la séance sur les modèles de transition végétale afin de simuler l'évolution de parcelles
# entre trois états : Barren (sol nu), Grasses (herbes) et Shrubs (arbustes). 
# L'objectif est de simuler une intervention écologique et d'évaluer son efficacité en comparant le scénario de base à un scénario modifié. 

# # Présentation du modèle
# Le modèle repose sur une matrice de transition qui décrit la probabilité de passer d'un état à un autre à chaque génération. Les trois états étudiés sont Barren, Grasses et Shrubs.
# Le scénario de base correspond au code fourni en classe. Une intervention est ensuite simulée en modifiant la matrice de transition pour favoriser la végétalisation. 
# Les valeurs de la matrice sont ensuite normalisées afin de représenter des probabilités de transition.
 
# # Implémentation

# ## Packages nécessaires

import Random
Random.seed!(123456)
using CairoMakie

using Distributions

function check_transition_matrix!(T)
    for ligne in axes(T, 1)
        if sum(T[ligne, :]) != 1
            T[ligne, :] ./= sum(T[ligne, :])
        end
    end
    return T
end

function simulation(transitions, states; generations=200)
    check_transition_matrix!(transitions)
    timeseries = zeros(Float64, length(states), generations + 1)
    timeseries[:, 1] = states

    for g in 1:generations
        timeseries[:, g+1] = (timeseries[:, g]' * transitions)'
    end

    return timeseries
end

# États initiaux
s = [100, 0, 0]

# Matrice de transition de base
T = [
    110 8 0;
    2 120 3;
    1 0 94
]

T2 = copy(T)

# Intervention : favoriser la végétation
T2[1, :] = [80, 38, 0]
T2[2, :] = [1, 110, 14]

sim_base = simulation(T, s)
sim_intervention = simulation(T2, s)

# ## Inclure du code

# Tous les fichiers dans le dossier `code` peuvent être ajoutés au travail
# final. C'est par exemple utile pour déclarer l'ensemble des fonctions du
# modèle hors du document principal.

# Le contenu des fichiers est inclus avec `include("code/nom_fichier.jl")`.

# Attention! Il faut que le code soit inclus au bon endroit (avant que les
# fonctions déclarées soient appellées).


# ## Une autre section

"""
    foo(x, y)

Cette fonction ne fait rien.
"""
function foo(x, y)
    ## Cette ligne est un commentaire
    return nothing
end

# # Présentation des résultats

f = Figure()
ax = Axis(f[1,1], xlabel="Générations", ylabel="Nombre de parcelles")

colors = [:grey, :orange, :green]

# Simulation de base
for i in 1:3
    lines!(ax, sim_base[i, :], color=colors[i], label="Base $i")
end

# Simulation intervention (pointillé)
for i in 1:3
    lines!(ax, sim_intervention[i, :], color=colors[i], linestyle=:dash)
end

axislegend(ax)
f

# Les résultats montrent que l’intervention accélère la transition vers les arbustes.
# Les zones de sol nu diminuent plus rapidement comparativement au scénario de base.
# On remarque également que la dynamique du système est plus rapide avec l’intervention.


# # Discussion
# L’intervention simulée semble efficace pour accélérer la succession végétale vers un état dominé par les arbustes.
# En augmentant les transitions vers les états végétalisés, on réduit la proportion de sol nu plus rapidement.
#
# Ce modèle reste simplifié et théorique car il ne prend pas en compte plusieurs facteurs écologiques tels que
# les conditions environnementales, les perturbations ou les interactions entre espèces.
