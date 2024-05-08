webuse citytemp.dta, clear

decode division, gen(area)

preserve

bys area: egen my_num_obs = count(area) // Modify this line to change the variable to tabulate
local desired_max = 5 // Modify this line to change the number of distinct observations in the tabulate
gen my_rank = .
forvalues i = 1(1)`desired_max' {
	sum my_num_obs if my_rank == .
	replace my_rank = `i' if my_num_obs == r(max)
}
matrix mat_my_top = J(`desired_max'+1,3,.)
count
local my_tot = r(N)
matrix mat_my_top[`desired_max'+1,1] = `my_tot'
matrix mat_my_top[`desired_max'+1,2] = 100
forvalues i = 1(1)`desired_max' {
	count if my_rank == `i'
	matrix mat_my_top[`i',1] = r(N)
	matrix mat_my_top[`i',2] = (r(N)/`my_tot')*100
}
matrix mat_my_top[1,3] = mat_my_top[1,2]
forvalues i = 2(1)`desired_max' {
	matrix mat_my_top[`i',3] = mat_my_top[`i'-1,3]+mat_my_top[`i',2]
}
local the_rows = ""
forvalues i = 1(1)`desired_max' {
	levelsof area if my_rank == `i', local(my_name_`i') clean // Modify this line to change the variable to tabulate
	local this_row = "`my_name_`i''"
	local the_rows `" `the_rows' "`this_row'" "'
}
matrix rownames mat_my_top = `the_rows' "Total"
matrix colnames mat_my_top = "Frequency" "Percentage" "Cumulative percentage"
esttab matrix(mat_my_top, fmt(%7.0fc %7.3f %7.3f)) using example.tex, nomtitles replace

restore