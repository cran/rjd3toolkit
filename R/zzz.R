#' @include utils.R
NULL

#' @importFrom rJava .jcall .jnull .jarray .jevalArray .jcast .jcastToArray .jinstanceof is.jnull .jnew .jclass .jinit
#' @importFrom stats frequency is.ts pf ts ts.union
NULL

#' @rdname jd3_utilities
#' @export
.jd3_env <- new.env()

#' @importFrom rjd3jars check_java_version
.onAttach <- function(libname, pkgname) {
    # Check java version
    rjd3jars::check_java_version(silent = FALSE, startup = TRUE)
}

#' @importFrom RProtoBuf readProtoFiles2
#' @importFrom rJava .jpackage
#' @importFrom rjd3jars check_java_version reload_dictionaries
.onLoad <- function(libname, pkgname) {
    # Loading dependencies
    if (!requireNamespace("rjd3jars", quietly = TRUE)) {
        stop("Loading {rjd3jars} failed", call. = FALSE)
    }

    # Loading Java class
    jar_dir <- file.path(libname, pkgname, "inst", "java")
    jars_inst <- list.files(
        jar_dir,
        pattern = "\\.jar$",
        full.names = TRUE,
        all.files = TRUE
    )
    result <- rJava::.jpackage(
        pkgname,
        lib.loc = libname,
        morePaths = jars_inst
    )
    if (!result) {
        stop("Loading java packages failed")
    }

    has_java <- rjd3jars::check_java_version(silent = TRUE)
    if (has_java) {
        rjd3jars::reload_dictionaries()
    }

    # Loading Proto class
    proto.dir <- system.file("proto", package = pkgname)
    RProtoBuf::readProtoFiles2(protoPath = proto.dir)

    # Set options
    if (is.null(getOption("summary_info"))) {
        options(summary_info = TRUE)
    }
}


#' @rdname jd3_utilities
get_date_min <- function() {
    return(dateOf(1, 1, 1))
}

#' @rdname jd3_utilities
get_date_max <- function() {
    return(dateOf(9999, 12, 31))
}

#' @title Set an option for toolkit
#'
#' @param name Name of the option
#' @param obj Option
#'
#' @export
#'
#' @examples
#' toolkit_option("test", "DUMMY")
toolkit_option <- function(name, obj) {
    options <- .jd3_env$toolkit
    options[[name]] <- obj
    assign("toolkit", options, rjd3toolkit::.jd3_env)
    return(invisible(NULL))
}

#' @title Set an option for toolkit
#'
#' @param name Name of the option
#'
#' @returns The requested option or NULL if it doesn't exist
#' @export
#'
#' @examples
#' toolkit_option("test", "DUMMY")
#' get_toolkit_option("test")
get_toolkit_option <- function(name) {
    options <- .jd3_env$toolkit
    return (options[[name]])
}
