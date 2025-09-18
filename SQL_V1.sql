-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.TDETALLEVENTA (
  IDDETALLE integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDVENTA integer,
  IDPRODUCTO integer,
  CANTIDAD integer,
  METODOPAGO character varying,
  PRECIO_UNITARIO numeric,
  SUBTOTAL numeric,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TDETALLEVENTA_pkey PRIMARY KEY (IDDETALLE),
  CONSTRAINT TDETALLEVENTA_IDVENTA_fkey FOREIGN KEY (IDVENTA) REFERENCES public.TVENTA(IDVENTA),
  CONSTRAINT TDETALLEVENTA_IDPRODUCTO_fkey FOREIGN KEY (IDPRODUCTO) REFERENCES public.TPRODUCTO(IDPRODUCTO)
);
CREATE TABLE public.TDIRECCION_CLIENTE (
  IDDIRECCION integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDENTIFICACION character varying,
  NOMBRE_DIRECCION character varying NOT NULL,
  DIRECCION character varying,
  REFERENCIA character varying,
  ES_PRINCIPAL boolean,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  ESTADO character varying NOT NULL,
  CONSTRAINT TDIRECCION_CLIENTE_pkey PRIMARY KEY (IDDIRECCION),
  CONSTRAINT TDIRECCION_CLIENTE_IDENTIFICACION_fkey FOREIGN KEY (IDENTIFICACION) REFERENCES public.TPERSONA(IDENTIFICACION)
);
CREATE TABLE public.TDISPOSITIVO (
  IDDISPOSITIVO integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDUSUARIO integer NOT NULL,
  IMEI character varying UNIQUE,
  MARCA character varying,
  MODELO character varying,
  ULTIMOACCESO timestamp without time zone,
  SISTEMAOPERATIVO character varying,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TDISPOSITIVO_pkey PRIMARY KEY (IDDISPOSITIVO),
  CONSTRAINT TDISPOSITIVO_IDUSUARIO_fkey FOREIGN KEY (IDUSUARIO) REFERENCES public.TUSUARIO(IDUSUARIO)
);
CREATE TABLE public.TENTREGA (
  IDENTREGA integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDVENTA integer NOT NULL,
  IDENTIFICACION_REPARTIDOR character varying NOT NULL,
  IDDIRECCION integer NOT NULL,
  FECHA_ASIGNACION timestamp without time zone,
  FECHA_ENTREGA timestamp without time zone,
  ESTADO character varying,
  COMENTARIO character varying,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TENTREGA_pkey PRIMARY KEY (IDENTREGA),
  CONSTRAINT TENTREGA_IDVENTA_fkey FOREIGN KEY (IDVENTA) REFERENCES public.TVENTA(IDVENTA),
  CONSTRAINT TENTREGA_IDDIRECCION_fkey FOREIGN KEY (IDDIRECCION) REFERENCES public.TDIRECCION_CLIENTE(IDDIRECCION),
  CONSTRAINT TENTREGA_IDENTIFICACION_REPARTIDOR_fkey FOREIGN KEY (IDENTIFICACION_REPARTIDOR) REFERENCES public.TPERSONA(IDENTIFICACION)
);
CREATE TABLE public.TFACTURA (
  IDFACTURA integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDVENTA integer UNIQUE,
  IDCLIENTE character varying,
  NUMEROFACTURA character varying UNIQUE,
  FECHA timestamp without time zone,
  TOTAL numeric,
  COMENTARIO character varying,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TFACTURA_pkey PRIMARY KEY (IDFACTURA),
  CONSTRAINT TFACTURA_IDVENTA_fkey FOREIGN KEY (IDVENTA) REFERENCES public.TVENTA(IDVENTA)
);
CREATE TABLE public.TINGRESO_EGRESO (
  IDMOVIMIENTO integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDSUCURSAL integer NOT NULL,
  TIPO character varying,
  CATEGORIA character varying,
  DESCRIPCION character varying,
  MONTO numeric,
  FECHA timestamp without time zone,
  REFERENCIA character varying,
  ESTADO character varying,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TINGRESO_EGRESO_pkey PRIMARY KEY (IDMOVIMIENTO),
  CONSTRAINT TINGRESO_EGRESO_IDSUCURSAL_fkey FOREIGN KEY (IDSUCURSAL) REFERENCES public.TSUCURSAL(IDSUCURSAL)
);
CREATE TABLE public.TINVENTARIO (
  IDINVENTARIO integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDSUCURSAL integer NOT NULL,
  NOMBRE character varying NOT NULL,
  DESCRIPCION character varying,
  CATEGORIA character varying,
  STOCK integer,
  PRECIO_UNITARIO numeric,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  ESTADO character varying,
  CONSTRAINT TINVENTARIO_pkey PRIMARY KEY (IDINVENTARIO),
  CONSTRAINT TINVENTARIO_IDSUCURSAL_fkey FOREIGN KEY (IDSUCURSAL) REFERENCES public.TSUCURSAL(IDSUCURSAL)
);
CREATE TABLE public.TMESA (
  IDMESA integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDSUCURSAL integer,
  NUMERO integer,
  ESTADO character varying,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TMESA_pkey PRIMARY KEY (IDMESA),
  CONSTRAINT TMESA_IDSUCURSAL_fkey FOREIGN KEY (IDSUCURSAL) REFERENCES public.TSUCURSAL(IDSUCURSAL)
);
CREATE TABLE public.TPERSONA (
  IDENTIFICACION character varying NOT NULL,
  NOMBRES character varying NOT NULL,
  APELLIDOS character varying NOT NULL,
  FNACIMIENTO timestamp without time zone,
  GENERO character varying,
  CORREO character varying,
  TELEFONO character varying,
  DIRECCION character varying,
  TIPOIDENTIFICACION character varying,
  ESTADO character varying,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TPERSONA_pkey PRIMARY KEY (IDENTIFICACION)
);
CREATE TABLE public.TPLANILLA (
  IDPLANILLA integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDSUCURSAL integer NOT NULL,
  IDENTIFICACION character varying,
  PERIODO character varying,
  SUELDO_BASE numeric,
  COMISION numeric,
  BONIFICACION numeric,
  DESCUENTO numeric,
  TOTAL_PAGAR numeric,
  FECHA_PAGO date,
  ESTADO character varying NOT NULL,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TPLANILLA_pkey PRIMARY KEY (IDPLANILLA),
  CONSTRAINT TPLANILLA_IDENTIFICACION_fkey FOREIGN KEY (IDENTIFICACION) REFERENCES public.TPERSONA(IDENTIFICACION),
  CONSTRAINT TPLANILLA_IDSUCURSAL_fkey FOREIGN KEY (IDSUCURSAL) REFERENCES public.TSUCURSAL(IDSUCURSAL)
);
  CREATE TABLE public.TPRODUCTO (
    IDPRODUCTO integer GENERATED ALWAYS AS IDENTITY NOT NULL,
    IDSUCURSAL integer NOT NULL,
    NOMBRE character varying NOT NULL,
    DESCRIPCION character varying NOT NULL,
    PRECIO numeric NOT NULL,
    CATEGORIA character varying NOT NULL,
    IMAGEN character varying,
    DISPONIBLE boolean,
    FCREACION timestamp without time zone,
    FMODIFICACION timestamp without time zone,
    USUARIOINGRESO character varying,
    USERMODIFICACION character varying,
    ESTADO character varying,
    CONSTRAINT TPRODUCTO_pkey PRIMARY KEY (IDPRODUCTO)
  );
CREATE TABLE public.TPRODUCTO_INSUMO (
  IDPRODUCTO_INSUMO integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDPRODUCTO integer NOT NULL,
  IDINVENTARIO integer,
  CANTIDAD integer,
  CONSTRAINT TPRODUCTO_INSUMO_pkey PRIMARY KEY (IDPRODUCTO_INSUMO),
  CONSTRAINT TPRODUCTO_INSUMO_IDINVENTARIO_fkey FOREIGN KEY (IDINVENTARIO) REFERENCES public.TINVENTARIO(IDINVENTARIO),
  CONSTRAINT TPRODUCTO_INSUMO_IDPRODUCTO_fkey FOREIGN KEY (IDPRODUCTO) REFERENCES public.TPRODUCTO(IDPRODUCTO)
);
CREATE TABLE public.TROL (
  IDROL integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  NOMBRE character varying NOT NULL,
  FCREACION timestamp without time zone NOT NULL,
  FMODIFICACION timestamp without time zone,
  OBSERVACION character varying,
  ESTADO character varying NOT NULL,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TROL_pkey PRIMARY KEY (IDROL)
);
CREATE TABLE public.TROLUSUARIO (
  IDROLUSUARIO integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDUSUARIO integer NOT NULL,
  IDROL integer,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  ESTADO character varying,
  CONSTRAINT TROLUSUARIO_pkey PRIMARY KEY (IDROLUSUARIO),
  CONSTRAINT TROLUSUARIO_IDROL_fkey FOREIGN KEY (IDROL) REFERENCES public.TROL(IDROL),
  CONSTRAINT TROLUSUARIO_IDUSUARIO_fkey FOREIGN KEY (IDUSUARIO) REFERENCES public.TUSUARIO(IDUSUARIO)
);
CREATE TABLE public.TSESION (
  IDSESION uuid NOT NULL DEFAULT gen_random_uuid(),
  IDUSUARIO integer NOT NULL,
  TOKEN uuid NOT NULL UNIQUE,
  FCREACION timestamp with time zone DEFAULT now(),
  FEXPIRACION timestamp with time zone NOT NULL,
  ACTIVO boolean DEFAULT true,
  CONSTRAINT TSESION_pkey PRIMARY KEY (IDSESION),
  CONSTRAINT tsesion_idusuario_fkey FOREIGN KEY (IDUSUARIO) REFERENCES public.TUSUARIO(IDUSUARIO)
);
CREATE TABLE public.TSUCURSAL (
  IDSUCURSAL integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  NOMBRE character varying NOT NULL,
  DIRECCION character varying NOT NULL,
  ESTADO boolean,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TSUCURSAL_pkey PRIMARY KEY (IDSUCURSAL)
);
CREATE TABLE public.TUSUARIO (
  IDUSUARIO integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDSUCURSAL integer NOT NULL,
  IDENTIFICACION character varying NOT NULL,
  USUARIO character varying UNIQUE,
  PASSWORD character varying,
  TEMPORAL boolean,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TUSUARIO_pkey PRIMARY KEY (IDUSUARIO),
  CONSTRAINT TUSUARIO_IDSUCURSAL_fkey FOREIGN KEY (IDSUCURSAL) REFERENCES public.TSUCURSAL(IDSUCURSAL),
  CONSTRAINT TUSUARIO_IDENTIFICACION_fkey FOREIGN KEY (IDENTIFICACION) REFERENCES public.TPERSONA(IDENTIFICACION)
);
CREATE TABLE public.TVENTA (
  IDVENTA integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  IDMESA integer NOT NULL,
  CLIENTE character varying NOT NULL,
  IDEMPLEADO integer NOT NULL,
  TIPO_VENTA character varying,
  FECHA timestamp without time zone,
  SUBTOTAL numeric,
  DELIVERY numeric,
  TOTAL numeric,
  ESTADO character varying,
  CONFACTURA boolean,
  COMENTARIO character varying,
  FCREACION timestamp without time zone,
  FMODIFICACION timestamp without time zone,
  USUARIOINGRESO character varying,
  USERMODIFICACION character varying,
  CONSTRAINT TVENTA_pkey PRIMARY KEY (IDVENTA),
  CONSTRAINT TVENTA_CLIENTE_fkey FOREIGN KEY (CLIENTE) REFERENCES public.TPERSONA(IDENTIFICACION),
  CONSTRAINT TVENTA_IDMESA_fkey FOREIGN KEY (IDMESA) REFERENCES public.TMESA(IDMESA),
  CONSTRAINT TVENTA_IDEMPLEADO_fkey FOREIGN KEY (IDEMPLEADO) REFERENCES public.TUSUARIO(IDUSUARIO)
);

----- =========================================
-- 0️⃣ LIMPIAR POLÍTICAS EXISTENTES
-- =========================================
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I;', r.policyname, r.schemaname, r.tablename);
    END LOOP;
END
$$;

-- =========================================
-- 1️⃣ HABILITAR RLS EN TABLAS PROTEGIDAS
-- =========================================
DO $$
DECLARE
    tbl RECORD;
    free_tables text[] := ARRAY['TUSUARIO','TDISPOSITIVO','TSESION','migrations','schema_migrations'];
BEGIN
    FOR tbl IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
          AND NOT (tablename = ANY(free_tables))
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl.tablename);

        EXECUTE format('
            CREATE POLICY require_session ON public.%I
            FOR ALL
            USING (
                EXISTS (
                    SELECT 1 FROM public."TSESION" s
                    WHERE s."IDUSUARIO" = current_setting(''app.current_user_id'', true)::int
                      AND s."ACTIVO" = true
                      AND now() <= s."FEXPIRACION"
                )
                OR current_setting(''is_admin'', true) = ''true''
            )
        ', tbl.tablename);
    END LOOP;
END
$$;

-- =========================================
-- 2️⃣ DESHABILITAR RLS EN TUSUARIO Y TDISPOSITIVO
-- =========================================
ALTER TABLE public."TUSUARIO" DISABLE ROW LEVEL SECURITY;
ALTER TABLE public."TDISPOSITIVO" DISABLE ROW LEVEL SECURITY;
ALTER TABLE public."TSESION" DISABLE ROW LEVEL SECURITY;

-- =========================================
-- 3️⃣ FUNCIONES DE AUTENTICACION Y GESTION DE SESIONES
-- =========================================

-- LOGIN SEGURO
CREATE OR REPLACE FUNCTION public.authenticate_user_secure(
    input_usuario TEXT,
    input_password_hash TEXT,
    device_imei TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_record RECORD;
    persona_record RECORD;
    device_record RECORD;
    user_id_numeric INTEGER;
    session_token UUID;
    session_duration INTERVAL := '4 hours';
BEGIN
    -- Validar usuario
    SELECT * INTO user_record
    FROM public."TUSUARIO"
    WHERE "USUARIO" = input_usuario
      AND "PASSWORD" = input_password_hash;

    IF user_record IS NULL THEN
        PERFORM pg_sleep(0.5);
        RETURN json_build_object('success', false, 'message', 'Credenciales inválidas');
    END IF;

    user_id_numeric := user_record."IDUSUARIO";

    -- Verificar dispositivo
    IF device_imei IS NOT NULL THEN
        SELECT * INTO device_record
        FROM public."TDISPOSITIVO"
        WHERE "IMEI" = device_imei
          AND "IDUSUARIO" = user_id_numeric;

        IF device_record IS NULL THEN
            RETURN json_build_object('success', false, 'message', 'Dispositivo no autorizado');
        END IF;

        UPDATE public."TDISPOSITIVO"
        SET "ULTIMOACCESO" = now(),
            "FMODIFICACION" = now(),
            "USERMODIFICACION" = input_usuario
        WHERE "IMEI" = device_imei;
    END IF;

    -- Obtener persona
    SELECT * INTO persona_record
    FROM public."TPERSONA"
    WHERE "IDENTIFICACION" = user_record."IDENTIFICACION";

    IF persona_record IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Datos de usuario incompletos');
    END IF;

    -- Generar token
    session_token := gen_random_uuid();

    -- Registrar sesión en TSESION
    INSERT INTO public."TSESION" (
        "IDUSUARIO", "TOKEN", "FCREACION", "FEXPIRACION", "ACTIVO"
    ) VALUES (
        user_id_numeric, session_token, now(), now() + session_duration, true
    );

    RETURN json_build_object(
        'success', true,
        'message', 'TRANSACCION CON EXITO',
        'session_token', session_token,
        'expires_at', extract(epoch from now() + session_duration)
    );
END;
$$;

-- REGISTRAR O VERIFICAR DISPOSITIVO
CREATE OR REPLACE FUNCTION public.register_or_verify_device(
    input_imei TEXT,
    input_usuario TEXT,
    device_marca TEXT DEFAULT NULL,
    device_modelo TEXT DEFAULT NULL,
    sistema_operativo TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    existing_device RECORD;
    user_id_numeric INTEGER;
BEGIN
    SELECT "IDUSUARIO" INTO user_id_numeric
    FROM public."TUSUARIO"
    WHERE "USUARIO" = input_usuario;

    IF user_id_numeric IS NULL THEN
        RETURN json_build_object('success', false, 'message', 'Usuario no existe');
    END IF;

    SELECT * INTO existing_device
    FROM public."TDISPOSITIVO"
    WHERE "IMEI" = input_imei;

    IF existing_device IS NOT NULL THEN
        IF existing_device."IDUSUARIO" = user_id_numeric THEN
            UPDATE public."TDISPOSITIVO"
            SET "ULTIMOACCESO" = now(),
                "FMODIFICACION" = now(),
                "USERMODIFICACION" = input_usuario
            WHERE "IMEI" = input_imei;
            RETURN json_build_object('success', true, 'message', 'TRANSACCION CON EXITO');
        ELSE
            RETURN json_build_object('success', false, 'message', 'Dispositivo registrado por otro usuario');
        END IF;
    ELSE
        INSERT INTO public."TDISPOSITIVO" (
            "IDUSUARIO","IMEI","MARCA","MODELO","ULTIMOACCESO",
            "SISTEMAOPERATIVO","FCREACION","FMODIFICACION","USUARIOINGRESO","USERMODIFICACION"
        ) VALUES (
            user_id_numeric,
            input_imei,
            COALESCE(device_marca,'Desconocida'),
            COALESCE(device_modelo,'Desconocido'),
            now(),
            COALESCE(sistema_operativo,'Desconocido'),
            now(),
            now(),
            input_usuario,
            input_usuario
        );
        RETURN json_build_object('success', true, 'message', 'TRANSACCION CON EXITO');
    END IF;
END;
$$;

-- LIMPIEZA DE SESIONES EXPIRADAS
CREATE OR REPLACE FUNCTION public.cleanup_expired_sessions()
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public."TSESION"
    WHERE "FEXPIRACION" < now();
    RAISE NOTICE 'Sesiones expiradas eliminadas';
END;
$$;
--REGLAS