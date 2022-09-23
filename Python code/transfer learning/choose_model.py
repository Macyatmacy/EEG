from braindecode.models.deep4 import Deep4Net
from braindecode.models.deep6 import Deep6Net
from braindecode.models.deep_re import DeepReNet
from braindecode.models.hybrid import HybridNet
from braindecode.models.shallow_fbcsp import ShallowFBCSPNet
from torch.nn.quantized.functional import leaky_relu


def choose_model(model_type,in_chans,n_classes,input_time_length):
    if model_type == "shallow":
        model = ShallowFBCSPNet(
            in_chans,
            n_classes,
            input_time_length=input_time_length,
            final_conv_length=50,
            drop_prob=0.001
        ).cuda()
        lr = 0.0625 * 0.01
        weight_decay = 0
    elif model_type == "deep4":
        model = Deep4Net(
            in_chans,
            n_classes,
            input_time_length=input_time_length,
            final_conv_length='auto',
            n_filters_time=25,
            n_filters_spat=25,
            filter_time_length=10,
            pool_time_length=3,
            pool_time_stride=3,
            n_filters_2=50,
            filter_length_2=10,
            n_filters_3=100,
            filter_length_3=10,
            n_filters_4=200,
            filter_length_4=10,
            first_nonlin=leaky_relu,
            first_pool_mode='max',
            # first_pool_nonlin=safe_log,
            later_nonlin=leaky_relu,
            later_pool_mode='max',
            # later_pool_nonlin=safe_log,
            drop_prob=0.001,
            double_time_convs=False,
            split_first_layer=True,
            batch_norm=True,
            batch_norm_alpha=0.1,
            stride_before_pool=False).cuda()
        lr = 1 * 0.0001
        weight_decay = 0.5 * 0.001
    elif model_type == "deep6":
        model = Deep6Net(
            in_chans,
            n_classes,
            input_time_length=input_time_length,
            final_conv_length='auto',
            n_filters_time=20,
            n_filters_spat=20,
            filter_time_length=5,
            pool_time_length=3,
            pool_time_stride=3,
            n_filters_2=20,
            filter_length_2=5,
            n_filters_3=40,
            filter_length_3=5,
            n_filters_4=80,
            filter_length_4=5,
            n_filters_5=160,
            filter_length_5=5,
            n_filters_6=320,
            filter_length_6=5,
            first_nonlin=leaky_relu,
            first_pool_mode='mean',
            # first_pool_nonlin=safe_log,
            later_nonlin=leaky_relu,
            later_pool_mode='mean',
            # later_pool_nonlin=safe_log,
            drop_prob=0.001,
            double_time_convs=False,
            split_first_layer=True,
            batch_norm=True,
            batch_norm_alpha=0.1,
            stride_before_pool=False).cuda()
        lr = 1 * 0.0001
        weight_decay = 0.5 * 0.00001
    elif model_type == "deep6_big":
        model = Deep6Net(
            in_chans,
            n_classes,
            input_time_length=input_time_length,
            final_conv_length='auto',
            n_filters_time=40,
            n_filters_spat=40,
            filter_time_length=5,
            pool_time_length=3,
            pool_time_stride=3,
            n_filters_2=20,
            filter_length_2=5,
            n_filters_3=40,
            filter_length_3=3,
            n_filters_4=80,
            filter_length_4=3,
            n_filters_5=160,
            filter_length_5=3,
            n_filters_6=320,
            filter_length_6=3,
            first_nonlin=leaky_relu,
            first_pool_mode='mean',
            # first_pool_nonlin=safe_log,
            later_nonlin=leaky_relu,
            later_pool_mode='mean',
            # later_pool_nonlin=safe_log,
            drop_prob=0.001,
            double_time_convs=False,
            split_first_layer=True,
            batch_norm=True,
            batch_norm_alpha=0.1,
            stride_before_pool=False).cuda()
        lr = 1 * 0.001
        weight_decay = 0.5 * 0.001
    elif model_type == "hyb":
        model = HybridNet(in_chans=in_chans, n_classes=n_classes, input_time_length=input_time_length).cuda()
        lr = 0.0625 * 0.01
        weight_decay = 0
    elif model_type == "deep6_Re":
        model = DeepReNet(
            in_chans,
            n_classes,
            input_time_length=input_time_length,
            final_conv_length='auto',
            n_filters_time=40,
            n_filters_spat=40,
            filter_time_length=5,
            pool_time_length=3,
            pool_time_stride=3,
            n_filters_2=40,
            filter_length_2=5,
            n_filters_3=40,
            filter_length_3=3,
            n_filters_4=100,
            filter_length_4=3,
            n_filters_5=250,
            filter_length_5=3,
            n_filters_6=500,
            filter_length_6=3,
            first_nonlin=leaky_relu,
            first_pool_mode="mean",
            # first_pool_nonlin = identity,
            later_nonlin=leaky_relu,
            later_pool_mode="mean",
            # later_pool_nonlin = identity,
            drop_prob=0.001,
            double_time_convs=False,
            split_first_layer=True,
            batch_norm=True,
            batch_norm_alpha=0.1,
            stride_before_pool=False, ).cuda()
        lr = 1 * 0.01
        weight_decay = 0.5 * 0.001
    elif model_type == "cooney":
            model = Deep6Net(
                in_chans,
                n_classes,
                input_time_length=input_time_length,
                final_conv_length='auto',
                n_filters_time=20,
                n_filters_spat=20,
                filter_time_length=5,
                pool_time_length=3,
                pool_time_stride=3,
                n_filters_2=20,
                filter_length_2=5,
                n_filters_3=40,
                filter_length_3=3,
                n_filters_4=100,
                filter_length_4=3,
                n_filters_5=250,
                filter_length_5=3,
                n_filters_6=500,
                filter_length_6=3,
                first_nonlin=leaky_relu,
                first_pool_mode='mean',
                later_nonlin=leaky_relu,
                later_pool_mode='mean',
                drop_prob=0.001,
                double_time_convs=False,
                split_first_layer=True,
                batch_norm=True,
                batch_norm_alpha=0.1,
                stride_before_pool=False).cuda()
            lr = 1 * 0.0001
            weight_decay = 0
    return model,lr,weight_decay