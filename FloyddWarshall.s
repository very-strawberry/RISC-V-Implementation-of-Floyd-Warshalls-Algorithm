.data
dist: .word 0, 3, 500, 7, 8, 0, 2, 500, 5, 500, 0, 1, 2, 500,500, 0  # 4x4 matrix

.text
la x24, dist       # Load base address of the dist matrix into x24
li x26, 4          # Dimension of the matrix (4x4)
li x27, 500        # Value representing "infinity"
li x8, 0           # i = 0, outer loop (for rows)

loop1:
    bge x8, x26, exit  # Exit if i >= 4
    li x6, 0           # k = 0, middle loop (for intermediate nodes)

loop2:
    bge x6, x26, loop1a  # Move to next row if k >= 4
    li x7, 0             # j = 0, inner loop (for columns)

loop3:
    bge x7, x26, loop2a  # Move to next k if j >= 4

    # Calculate address for dist[i][j]
    slli x10, x8, 2        # x10 = i * 4
    add x10, x10, x7       # x10 = i * 4 + j
    slli x10, x10, 2       # x10 = (i * 4 + j) * 4
    add x11, x24, x10      # x11 = base + (i * 4 + j) * 4
    lw x3, 0(x11)          # x3 = dist[i][j]

    # Calculate address for dist[i][k]
    slli x12, x8, 2        # x12 = i * 4
    add x12, x12, x6       # x12 = i * 4 + k
    slli x12, x12, 2       # x12 = (i * 4 + k) * 4
    add x13, x24, x12      # x13 = base + (i * 4 + k) * 4
    lw x4, 0(x13)          # x4 = dist[i][k]

    # Calculate address for dist[k][j]
    slli x14, x6, 2        # x14 = k * 4
    add x14, x14, x7       # x14 = k * 4 + j
    slli x14, x14, 2       # x14 = (k * 4 + j) * 4
    add x15, x24, x14      # x15 = base + (k * 4 + j) * 4
    lw x5, 0(x15)          # x5 = dist[k][j]

    # Skip update if dist[i][k] or dist[k][j] is infinity
    beq x4, x27, next
    beq x5, x27, next

    # Check if dist[i][k] + dist[k][j] < dist[i][j]
    add x23, x4, x5        # x23 = dist[i][k] + dist[k][j]
    blt x23, x3, update    # If (dist[i][k] + dist[k][j]) < dist[i][j], then update

next:
    addi x7, x7, 1         # j++
    j loop3                # Repeat inner loop

update:
    sw x23, 0(x11)         # Update dist[i][j] with the new minimum
    j next                 # Continue with the inner loop

loop2a:
    addi x6, x6, 1         # k++
    j loop2                # Repeat middle loop

loop1a:
    addi x8, x8, 1         # i++
    j loop1                # Repeat outer loop

exit:
    nop                    # Exit