########################
## code developped to build the heatmap figures
## that representes the results of the different choices of an agent or a human
## having to collaborate, according the state of its/his/her game partner
## figures used  to illustrate the behaviours of an agent (or a human) 
## Illustration used in the proposal
## "Matrices based on Descriptors for Analyzing the Interactions between Agents and Humans"
## Emmanuel Adam, Martial Razakatiana, René Mandiau, and Christophe Kolski
## -------
## as it is a code just plan for a private usage to illustrate a part of the article and o other usage
## I apologize for the lack of commentary and its no pedagogical aspect
## Nevertheless, I tried to rewrite a most lisible code, at the expense of the efficiency
## -------
## Source in JULIA language
## Author : E.ADAM
## Date : February 2023
########################

using LinearAlgebra
using Plots
using ImageView

@enum Category  C1=1 C2=2

#bounds values of a criteria 
const BOUND = 5
const v_max = BOUND
const v_min = 1

game_mat_C1 = zeros(2, 2, 2)
game_mat_C1_crt = zeros(2, 2, 2)
game_mat_C2 = zeros(2, 2, 2)


######################## NASH EQUILIBIRUM : H against A (H starts)
function eq_nash_h_start(game_mat, v_a::Int64, v_h::Int64, v_fix, category = C1::Category)
    coop_mat_A = zeros(Int64, BOUND + 1, BOUND + 1)
    coop_mat_H = zeros(Int64, BOUND + 1, BOUND + 1)
    h_choice = a_choice = 0
    h_gain = a_gain = -1
    if category == C1::Category && v_h < v_fix
        h_choice = 1
    end
    if category == C2::Category && v_h > v_fix
        h_choice = 1
    end
    h_choice_old = a_choice_old = -1
    step::Int64=0
    while (h_choice != h_choice_old) && (a_choice != a_choice_old) && step<2
        h_choice_old = h_choice
        a_choice_old = a_choice
        a_choice = 0
        if game_mat[1,h_choice+1,1] < game_mat[2,h_choice+1,1]
            a_choice = 1
        end
        a_gain = game_mat[a_choice+1,h_choice+1,1]
        h_gain = game_mat[a_choice+1,h_choice+1,2]
        h_choice = 0
        if game_mat[a_choice+1,1,2] < game_mat[a_choice+1,2,2]
            h_choice = 1
        end
        a_gain = game_mat[a_choice+1,h_choice+1,1]
        h_gain = game_mat[a_choice+1,h_choice+1,2]
        step += 1
    end
    coop_mat_A[v_a+1, v_h+1] = (1 - a_choice)
    coop_mat_H[v_a+1, v_h+1] = (1 - h_choice)
    return coop_mat_A, coop_mat_H
end
######################## END NASH EQUILIBIRUM : H against A (H starts)


######################## NASH EQUILIBIRUM : H against A (A starts)
function eq_nash_a_start(game_mat, v_a::Int64, v_h::Int64, v_fix, category = C1::Category)
    coop_mat_A = zeros(BOUND + 1, BOUND + 1)
    coop_mat_H = zeros(BOUND + 1, BOUND + 1)
    h_choice = a_choice = 0
    h_gain = a_Gain = -1
    if category == C1::Category && v_h < v_fix
        a_choice = 1
    end
    if category == C2::Category && v_h > v_fix
        a_choice = 1
    end
    h_choice_old = a_choice_old = -1
    step::Int64=0
    while (h_choice != h_choice_old) && (a_choice != a_choice_old) && step<2
        h_choice_old = h_choice
        a_choice_old = a_choice
        h_choice = 0
        if game_mat[a_choice+1,1,2] < game_mat[a_choice+1,2,2]
            h_choice = 1
        end
        a_Gain = game_mat[a_choice+1,h_choice+1,1]
        h_Gain = game_mat[a_choice+1,h_choice+1,2]
        a_choice = 0
        if game_mat[1,h_choice+1,1] < game_mat[2,h_choice+1,1]
            a_choice = 1
        end
        a_Gain = game_mat[a_choice+1,h_choice+1,1]
        h_Gain = game_mat[a_choice+1,h_choice+1,2]
        step += 1
    end
    coop_mat_A[v_a+1, v_h+1] = 1 - a_choice
    coop_mat_H[v_a+1, v_h+1] = 1 - h_choice
    return coop_mat_A, coop_mat_H
end
######################## END NASH EQUILIBIRUM : H against A (A starts)



######################## TESTS WITH A FIXED DELTA (see article to know what is delta)
### To Simplify the use by the reviewers, this method has been redefined
## It takes into account  1 criteria of category 1, 1 criteria of category 2, and one criteria of criticality. 
## by changing the lambda parameters, one can choose to activate or not some criteria
## (so the parameter category is no more usefull)
## in this function human start, it's easy to change to see what happens when its the agent that initiates the game
function test_delta_k(delta::Float64, category=C1::Category)
    coop_mat_A_total = coop_mat_A = zeros(BOUND + 1, BOUND + 1)
    coop_mat_H_total = coop_mat_H = zeros(BOUND + 1, BOUND + 1)
    game_mat = zeros(2, 2, 2)
    lambda_crt = 0.
    lambda1 = 0.
    lambda2 = 1.
    v_fix = delta * v_max
    game_mat_C1[1,1,1] = 0
    game_mat_C1[1,1,2] = 0
    game_mat_C1[1,2,1] = 0
    game_mat_C1[1,2,2] = v_fix
    game_mat_C1[2,1,1] = v_fix
    game_mat_C1[2,1,2] = 0
    game_mat_C1[2,2,1] = v_min
    game_mat_C1[2,2,2] = v_min
    game_mat_C1_crt = game_mat_C1 .+ 0
    game_mat_C2[1,1,1] = v_fix
    game_mat_C2[1,1,2] = v_fix
    game_mat_C2[1,2,1] = v_min
    game_mat_C2[1,2,2] = 0
    game_mat_C2[2,1,1] = 0
    game_mat_C2[2,1,2] = v_min
    game_mat_C2[2,2,1] = 0
    game_mat_C2[2,2,2] = 0
    for v_h in 0:BOUND
        game_mat_C1[1,1,2] = v_h
        game_mat_C1[2,1,2] = v_h
        game_mat_C1_crt[1,1,1] = v_h
        game_mat_C1_crt[1,1,2] = v_h
        game_mat_C1_crt[1,2,1] = v_h
        game_mat_C1_crt[2,1,2] = v_h
        game_mat_C2[1,2,2] = v_h
        game_mat_C2[2,2,2] = v_h
        for v_a in 0:BOUND
            game_mat_C1[1,1,1] = v_a
            game_mat_C1[1,2,1] = v_a
            game_mat_C2[2,1,1] = v_a
            game_mat_C2[2,2,1] = v_a
            game_mat = (game_mat_C1_crt * lambda_crt) + (game_mat_C1*lambda1) + (game_mat_C2*lambda2) 
            coop_mat_A,coop_mat_H = eq_nash_h_start(game_mat, v_a, v_h, v_fix, category)
            coop_mat_A_total += coop_mat_A
            coop_mat_H_total += coop_mat_H
        end
    end
    return coop_mat_A_total, coop_mat_H_total, game_mat
end
######################## END TESTS ONE CATEGORY WITH A FIXED DELTA



######################## TESTS THREE CATEGORIES WITH DELTAs between 0 and 1 (see article to know what is delta)
## call the previous method with specific deltas
function test_deltas()
    coop_mat_A_total = zeros(BOUND + 1, BOUND + 1)
    coop_mat_H_total = zeros(BOUND + 1, BOUND + 1)
    game_mat = zeros(2,2,2)
    for delta in 0:.1:1
        coop_mat_A, coop_mat_H,game_mat = test_delta_k(delta)
        coop_mat_A_total += coop_mat_A
        coop_mat_H_total += coop_mat_H
    end
    return coop_mat_A_total, coop_mat_H_total
end
######################## TESTS THREE CATEGORIES WITH DELTAs between 0 and 1 (see article to know what is delta)




MA,MH = test_deltas()

plot(heatmap(MA, c=:Blues, xticks =  (1:6, string.(0:5)),  yticks = (1:6, string.(0:5)) ), axis=("vA", "vH") , axpect_ratio=:equal, size=(400,400))
