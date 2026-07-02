using System;
using System.Data.SqlClient;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Registrarse : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] != null)
                Response.Redirect("~/Dashboard.aspx");
        }

        protected void btnRegistrarse_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            DateTime fechaNacimiento;
            if (!DateTime.TryParse(txtFechaNacimiento.Text, out fechaNacimiento))
            {
                MostrarError("Ingresá una fecha de nacimiento válida.");
                return;
            }

            if (txtPassword.Text != txtConfirmarPassword.Text)
            {
                MostrarError("Las contraseñas no coinciden.");
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
                Rol             = RolUsuario.Cliente
            };

            try
            {
                new NegocioUsuarios().Agregar(u, txtPassword.Text);
                Response.Redirect("~/Login.aspx?registro=ok");
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                MostrarError("Ya existe una cuenta con ese DNI o email.");
            }
            catch (Exception ex)
            {
                MostrarError("Error al crear la cuenta: " + ex.Message);
            }
        }

        private void MostrarError(string mensaje)
        {
            litError.Text = "<div class='auth-alert-error'>" + mensaje + "</div>";
            litError.Visible = true;
        }
    }
}
