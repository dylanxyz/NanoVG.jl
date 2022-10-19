using Clang.Generators
using NanoVG_jll

const Options = Dict{String, Any}

const include_dir = normpath(NanoVG_jll.artifact_dir, "include")
const nanovg_h = joinpath(include_dir, "nanovg.h")

const args = get_default_args()
push!(args, "-I$include_dir")

const options = Options(
    "general" => Options(
        "library_name"                => "libnanovg",
        "module_name"                 => "LibNanoVG",
        "jll_pkg_name"                => "NanoVG_jll",
        "jll_pkg_extra"               => ["GLEW_jll"],
        "output_file_path"            => "src/LibNanoVG.jl",
        "use_deterministic_symbol"    => true,
        "print_using_CEnum"           => true,
        "extract_c_comment_style"     => "doxygen",
        "struct_field_comment_style"  => "outofline",
        "enumerator_comment_style"    => "outofline",
        "export_symbol_prefixes"      => ["NVG", "nvg"],
        "union_single_constructor"    => "true",
        "epilogue_file_path"          => "./gen/epilogue.jl"
    ),

    "codegen" => Options(
        "use_julia_bool"                 => true,
        "always_NUL_terminated_string"   => true,
        "use_ccall_macro"                => true,
    ),

    "codegen.macro" => Options(
        "macro_mode"                     => "basic",
        "add_comment_for_skipped_macro"  => true,
        "ignore_header_guards"           => true,
    )
) # options

let ctx = create_context([nanovg_h], args, options)
    build!(ctx)
end

for gl in ("gl2", "gl3", "gles2", "gles3")
    path = joinpath("src", uppercase(gl) * ".jl")
    @info "Generating wrapper for libnanovg$gl"
    template = read(joinpath(@__DIR__, "template.jl"), String)
    write(path, replace(template,
        raw"$gl" => gl,
        raw"$GL" => uppercase(gl)
    ))
end
