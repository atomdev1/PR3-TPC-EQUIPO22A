using System;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Usuarios : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            // ABM de Usuarios exclusivo del Administrador.
            if (u.Rol != RolUsuario.Administrador)
            {
                Response.Redirect("~/Dashboard.aspx");
                return;
            }

            if (!IsPostBack)
            {
                CargarUsuarios();
            }
        }

        private void CargarUsuarios()
        {
            rptUsuarios.DataSource = new NegocioUsuarios().ObtenerTodos();
            rptUsuarios.DataBind();
        }

        // Alta: limpia el formulario, muestra los campos de contraseña y abre el modal.
        protected void btnNuevoUsuario_Click(object sender, EventArgs e)
        {
            hfIdUsuario.Value       = "";
            txtDNI.Text             = "";
            txtDNI.Enabled          = true;
            txtNombre.Text          = "";
            txtApellido.Text        = "";
            txtEmail.Text           = "";
            txtTelefono.Text        = "";
            txtFechaNacimiento.Text = "";
            ddlRol.SelectedValue    = "0";
            txtPassword.Text        = "";
            txtRepetirPassword.Text = "";
            pnlPassword.Visible     = true;
            lblError.Visible        = false;

            AbrirModal("Nuevo usuario");
        }

        protected void rptUsuarios_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idUsuario = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Usuario u = new NegocioUsuarios().ObtenerPorId(idUsuario);
                if (u == null) return;

                hfIdUsuario.Value       = u.IdUsuario.ToString();
                txtDNI.Text             = u.DNI;
                txtDNI.Enabled          = false; // el DNI es la identidad del usuario, no se edita
                txtNombre.Text          = u.Nombre;
                txtApellido.Text        = u.Apellido;
                txtEmail.Text           = u.Email;
                txtTelefono.Text        = u.Telefono;
                txtFechaNacimiento.Text = u.FechaNacimiento == DateTime.MinValue ? "" : u.FechaNacimiento.ToString("yyyy-MM-dd");
                ddlRol.SelectedValue    = ((int)u.Rol).ToString();
                pnlPassword.Visible     = false; // la contraseña no se cambia desde el ABM
                lblError.Visible        = false;

                AbrirModal("Editar usuario");
            }
            else if (e.CommandName == "Baja")
            {
                // No se da de baja directo, se pide confirmación con un panel.
                Usuario u = new NegocioUsuarios().ObtenerPorId(idUsuario);
                hfBajaId.Value = idUsuario.ToString();
                lblConfirmarBaja.Text = "¿Dar de baja al usuario \"" + (u != null ? u.Nombre + " " + u.Apellido : "") + "\"?";
                pnlConfirmarBaja.Visible = true;
            }
            else if (e.CommandName == "Reactivar")
            {
                new NegocioUsuarios().Reactivar(idUsuario);
                CargarUsuarios();
            }
        }

        protected void btnConfirmarBaja_Click(object sender, EventArgs e)
        {
            new NegocioUsuarios().BajaLogica(int.Parse(hfBajaId.Value));
            pnlConfirmarBaja.Visible = false;
            CargarUsuarios();
        }

        protected void btnCancelarBaja_Click(object sender, EventArgs e)
        {
            pnlConfirmarBaja.Visible = false;
        }

        protected void btnGuardarUsuario_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            DateTime fechaNacimiento;
            if (!DateTime.TryParse(txtFechaNacimiento.Text, out fechaNacimiento))
            {
                MostrarError("Ingresá una fecha de nacimiento válida.");
                return;
            }

            Usuario u = new Usuario
            {
                DNI             = txtDNI.Text.Trim(),
                Nombre          = txtNombre.Text.Trim(),
                Apellido        = txtApellido.Text.Trim(),
                Email           = txtEmail.Text.Trim(),
                Telefono        = txtTelefono.Text.Trim(),
                FechaNacimiento = fechaNacimiento,
                Rol             = (RolUsuario)int.Parse(ddlRol.SelectedValue)
            };

            try
            {
                NegocioUsuarios negocio = new NegocioUsuarios();
                if (string.IsNullOrEmpty(hfIdUsuario.Value))
                {
                    // Alta: la contraseña es obligatoria y debe coincidir (se valida en el servidor porque
                    // en edicion estos campos no se muestran).
                    if (txtPassword.Text.Length < 6)
                    {
                        MostrarError("La contraseña debe tener al menos 6 caracteres.");
                        return;
                    }
                    if (txtPassword.Text != txtRepetirPassword.Text)
                    {
                        MostrarError("Las contraseñas no coinciden.");
                        return;
                    }
                    negocio.Agregar(u, txtPassword.Text);
                }
                else
                {
                    u.IdUsuario = int.Parse(hfIdUsuario.Value);
                    negocio.Modificar(u);
                }
                Response.Redirect("Usuarios.aspx");
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                // violación del UNIQUE de DNI o Email
                MostrarError("Ya existe un usuario con ese DNI o email.");
            }
        }

        private void MostrarError(string mensaje)
        {
            lblError.Text = mensaje;
            lblError.Visible = true;

            // el modal se cierra con el postback, hay que reabrirlo para que se vea el error
            string titulo = string.IsNullOrEmpty(hfIdUsuario.Value) ? "Nuevo usuario" : "Editar usuario";
            AbrirModal(titulo);
        }

        private void AbrirModal(string titulo)
        {
            string script =
                "var lbl = document.getElementById('modalUsuarioLabel'); if (lbl) lbl.textContent = '" + titulo + "';" +
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalUsuario')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModalUsuario", script, true);
        }

        // Helpers de presentación para el Repeater
        protected string GetRolNombre(object rol)
        {
            switch ((RolUsuario)rol)
            {
                case RolUsuario.Administrador:   return "Administrador";
                case RolUsuario.Recepcionista:   return "Recepcionista";
                case RolUsuario.EncargadoCancha: return "Encargado de Cancha";
                default:                         return "Cliente";
            }
        }

        protected string GetEstadoTexto(object activo)
        {
            return (bool)activo ? "Activo" : "Inactivo";
        }

        protected string GetEstadoBadgeClass(object activo)
        {
            return (bool)activo ? "badge bg-success" : "badge bg-secondary";
        }
    }
}
