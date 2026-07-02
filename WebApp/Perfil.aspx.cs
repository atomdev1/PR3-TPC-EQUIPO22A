using System;
using Dominio;
using Dominio.Enums;
using Negocio;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace WebApp
{
    public partial class Perfil : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            if (!IsPostBack)
            {
                CargarDatos(u);
            }
        }

        private void CargarDatos(Usuario u)
        {
            lblNombre.Text = u.Nombre;
            lblApellido.Text = u.Apellido;
            lblDNI.Text = u.DNI;
            lblTelefono.Text = string.IsNullOrEmpty(u.Telefono) ? "—" : u.Telefono;
            lblEmail.Text = u.Email;
            lblFechaNacimiento.Text = u.FechaNacimiento.ToString("dd/MM/yyyy");
            lblFechaRegistro.Text = u.FechaRegistro.ToString("dd/MM/yyyy");
            lblRol.Text = u.Rol.ToString();

            pnlAsistencias.Visible = u.Rol == RolUsuario.Cliente;
            lblAsistencias.Text = u.CantidadAsistencias.ToString();

            txtNombre.Text = u.Nombre;
            txtApellido.Text = u.Apellido;
            txtTelefono.Text = u.Telefono ?? "";
        }

        protected void btnGuardarDatos_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            try
            {
                u.Nombre = txtNombre.Text.Trim();
                u.Apellido = txtApellido.Text.Trim();
                u.Telefono = txtTelefono.Text.Trim();

                new NegocioUsuarios().ActualizarPerfil(u);

                // Actualizar la sesión con los nuevos datos
                Session["usuario"] = u;

                lblExito.Text = "Datos actualizados correctamente.";
                lblExito.Visible = true;
                lblErrorEditar.Visible = false;

                CargarDatos(u);
            }
            catch (Exception ex)
            {
                lblErrorEditar.Text = "Error al guardar: " + ex.Message;
                lblErrorEditar.Visible = true;
            }
        }

        protected void btnCambiarPassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }

            if (txtPasswordNueva.Text != txtPasswordConfirm.Text)
            {
                lblErrorPassword.Text = "La nueva contraseña y la confirmación no coinciden.";
                lblErrorPassword.Visible = true;
                return;
            }

            try
            {
                bool ok = new NegocioUsuarios().CambiarContrasenia(
                    u.IdUsuario,
                    txtPasswordActual.Text,
                    txtPasswordNueva.Text);

                if (!ok)
                {
                    lblErrorPassword.Text = "La contraseña actual es incorrecta.";
                    lblErrorPassword.Visible = true;
                    return;
                }

                txtPasswordActual.Text = "";
                txtPasswordNueva.Text = "";
                txtPasswordConfirm.Text = "";

                lblExito.Text = "Contraseña cambiada correctamente.";
                lblExito.Visible = true;
                lblErrorPassword.Visible = false;
            }
            catch (Exception ex)
            {
                lblErrorPassword.Text = "Error al cambiar la contraseña: " + ex.Message;
                lblErrorPassword.Visible = true;
            }
        }
    }
}