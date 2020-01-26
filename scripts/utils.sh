# ------------------------------------------------------------------------------
#  General Purpose Build Utilities
# ------------------------------------------------------------------------------
function disp {
    case $2 in
        1)
            printf " -- $1 --"
            ;;
        2)
            printf "   * $1\n"
            ;;
        3)
            printf "     - $1\n"
            ;;
        4)
            printf "       + $1\n"
            ;;
        *)
            echo "Incorrect display level .. exit"
            exit 1
            ;;
    esac
}
