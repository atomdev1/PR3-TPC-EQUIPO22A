using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Cupones : CuponPageBase
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarCupones();
                CargarUsuarios();
            }
        }

        private void CargarCupones()
        {
            NegocioCupones nCupones = new NegocioCupones();
            List<Cupon> cupones = nCupones.ObtenerTodas();

            rptCupones.DataSource = cupones;
            rptCupones.DataBind();
        }

        private void CargarUsuarios()
        {
            NegocioCupones nCupones = new NegocioCupones();
            List<Usuario> usuarios = nCupones.ObtenerUsuarios();

            foreach (Usuario u in usuarios)
                ddlUsuario.Items.Add(new ListItem(u.Nombre + " " + u.Apellido, u.IdUsuario.ToString()));

            ddlUsuario.Items.Insert(0, new ListItem("-- Seleccioná un cliente --", "0"));
        }

        protected void rptCupones_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCupon = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Cupon c = new NegocioCupones().ObtenerPorId(idCupon);
                if (c == null) return;

                hfIdCupon.Value                    = c.IdCupon.ToString();
                txtCodigo.Text                     = c.Codigo;
                ddlTipoDescuento.SelectedValue     = ((int)c.TipoDescuento).ToString();
                txtValorDescuento.Text             = c.ValorDescuento.HasValue ? c.ValorDescuento.Value.ToString() : "";
                txtReservasRequeridas.Text         = c.ReservasRequeridas.ToString();
                txtValidoHasta.Text                = c.ValidoHasta.HasValue ? c.ValidoHasta.Value.ToString("yyyy-MM-dd") : "";
                txtLimiteUsos.Text                 = c.LimiteUsos.HasValue ? c.LimiteUsos.Value.ToString() : "";
                txtDescripcion.Text                = c.Descripcion;
                ddlUsuario.SelectedValue           = c.Usuario.IdUsuario.ToString();

                string script =
                    "document.getElementById('modalNuevoCuponLabel').textContent = 'Editar cupón';" +
                    "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalNuevoCupon')).show();";
                ClientScript.RegisterStartupScript(GetType(), "abrirModalCupon", script, true);
            }
            else if (e.CommandName == "Eliminar")
            {
                new NegocioCupones().BajaLogica(idCupon);
                CargarCupones();
            }
        }

        protected void btnGuardarCupon_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            TipoDescuento tipo = (TipoDescuento)int.Parse(ddlTipoDescuento.SelectedValue);

            // ReservaGratis no lleva valor; el resto sí es obligatorio
            decimal? valorDescuento;
            if (tipo == TipoDescuento.ReservaGratis)
            {
                valorDescuento = null;
            }
            else if (string.IsNullOrEmpty(txtValorDescuento.Text))
            {
                MostrarError("El valor del descuento es obligatorio para este tipo.");
                return;
            }
            else
            {
                valorDescuento = decimal.Parse(txtValorDescuento.Text);
            }

            Cupon cupon = new Cupon
            {
                Codigo = txtCodigo.Text.Trim().ToUpper(),
                TipoDescuento = tipo,
                ValorDescuento = valorDescuento,
                ReservasRequeridas = int.Parse(txtReservasRequeridas.Text),
                ValidoHasta = string.IsNullOrEmpty(txtValidoHasta.Text) ? (DateTime?)null : DateTime.Parse(txtValidoHasta.Text),
                LimiteUsos = string.IsNullOrEmpty(txtLimiteUsos.Text) ? (int?)null : int.Parse(txtLimiteUsos.Text),
                Descripcion = txtDescripcion.Text.Trim(),
                Usuario = new Usuario { IdUsuario = int.Parse(ddlUsuario.SelectedValue) }
            };

            try
            {
                NegocioCupones nCupones = new NegocioCupones();
                if (string.IsNullOrEmpty(hfIdCupon.Value))
                {
                    cupon.UsosActuales = 0;
                    cupon.Estado = EstadoCupon.Activo;
                    nCupones.Agregar(cupon);
                }
                else
                {
                    cupon.IdCupon = int.Parse(hfIdCupon.Value);
                    nCupones.Modificar(cupon);
                }
                Response.Redirect("Cupones.aspx");
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                // violación del UNIQUE de Codigo
                MostrarError("Ya existe un cupón con ese código. Usá uno distinto.");
            }
        }

        private void MostrarError(string mensaje)
        {
            lblError.Text = mensaje;
            lblError.Visible = true;

            // el modal se cierra con el postback → hay que reabrirlo para que se vea el error
            string titulo = string.IsNullOrEmpty(hfIdCupon.Value) ? "Nuevo cupón" : "Editar cupón";
            string script =
                "var lbl = document.getElementById('modalNuevoCuponLabel'); if (lbl) lbl.textContent = '" + titulo + "';" +
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('modalNuevoCupon')).show();";
            ClientScript.RegisterStartupScript(GetType(), "reabrirModalCupon", script, true);
        }

    }
}
